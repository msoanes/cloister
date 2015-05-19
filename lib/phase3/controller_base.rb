require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def controller_name
      self.class.name.underscore
    end

    def render(template_name)
      template_path = "views/#{controller_name}/#{template_name}.html.erb"

      template_string = File.read(template_path)
      template = ERB.new(template_string)
      render_content(template.result(binding), 'text/html')
    end
  end
end
