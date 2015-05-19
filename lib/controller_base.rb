require 'erb'
require_relative 'params'
require_relative 'session'

module Monastery
  class ControllerBase
    attr_reader :req, :res, :params

    def initialize(req, res, route_params = {})
      @req, @res, @params = req, res, Params.new(req, route_params)
    end

    def already_built_response?
      @already_built_response
    end

    def controller_name
      self.class.name.underscore
    end

    def invoke_action(name)
      send(name)
    end

    def redirect_to(url)
      res.status = 302
      res.header["location"] = url
      render_content("", 'text/html')
      session.store_session(res)
    end

    def render(template_name)
      template_path = "views/#{controller_name}/#{template_name}.html.erb"

      template_string = File.read(template_path)
      template = ERB.new(template_string)
      render_content(template.result(binding), 'text/html')
    end

    def render_content(content, content_type)
      raise if already_built_response?
      res.body = content
      res.content_type = content_type
      @already_built_response = true
      session.store_session(res)
    end

    def session
      @session ||= Session.new(req)
    end
  end
end
