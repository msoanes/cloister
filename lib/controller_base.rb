require 'erb'
require 'active_support'
require 'active_support/core_ext'

require_relative 'params'
require_relative 'session'
require_relative 'flash'

module Monastery
  class ControllerBase
    attr_reader :req, :res, :params


    def self.controller_name
      thing = /.+?(?=Controller$)/.match(name) || ['basic']
      thing[0]
    end

    def initialize(req, res, route_params = {}, named_paths = {})
      @req, @res, @params = req, res, Params.new(req, route_params)
      @named_paths = named_paths
    end

    def method_missing(method_name, *args, &prc)
      if method_name.to_s[-5..-1] == '_path'
        find_path(method_name.to_s[0...-5], *args)
      else
        super
      end
    end

    def already_built_response?
      @already_built_response
    end

    def button_to(text, uri, options = nil)
      options ||= { method: 'get' }
      <<-html
<form action="#{uri}" method="get">
  <input type="submit" value="#{text}">
</form>
      html

    end

    def find_path(path_name, *args)
      named_paths[path_name]
      parts = named_paths.split('/')
      parts.map { |part| part.gsub(/:(.+)[\/]{,1}/, args.shift) }
    end

    def invoke_action(name)
      raise if already_built_response?
      send(name)
      render unless already_built_response?
    end

    def link_to(text, uri)
      "<a href=\"#{url}\">#{text}</a>"
    end

    def redirect_to(url)
      res.status = 302
      res.header["location"] = url
      render_content("", 'text/html')
      flash.store_flash(res)
      session.store_session(res)
      @already_built_response = true
    end

    def render(template_name)
      controller_name = self.class.controller_name
      template_path = "views/#{controller_name}/#{template_name}.html.erb"

      template_string = File.read(template_path)
      template = ERB.new(template_string)
      render_content(template.result(binding), 'text/html')
    end

    def render_content(content, content_type)
      raise if already_built_response?
      res.body = content
      res.content_type = content_type
      session.store_session(res)
      flash.store_flash(res)
      @already_built_response = true
    end

    def session
      @session ||= Session.new(req)
    end

    def flash
      @flash ||= Flash.new(req)
    end
  end
end
