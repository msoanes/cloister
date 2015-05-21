module Monastery
  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern, @http_method, @controller_class, @action_name = pattern,
        http_method, controller_class, action_name
    end

    def matches?(req)
      methods_match = (req.request_method.downcase.to_sym == http_method)
      methods_match && (pattern =~ req.path)
    end

    def run(req, res, named_paths)
      match_data = pattern.match(req.path)
      route_params = {}
      match_data.names.each do |name|
        route_params[name] = match_data[name]
      end
      controller = controller_class.new(req, res, route_params, named_paths)
      controller.invoke_action(action_name)
    end
  end
end
