require_relative 'route'
require_relative 'route_resourcable'

module Monastery
  class Router
    include RouteResourcable
    attr_reader :routes

    def initialize
      @routes = []
    end

    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    def draw(&proc)
      instance_eval(&proc)
    end

    [:get, :post, :put, :delete].each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name|
        add_route(pattern, http_method, controller_class, action_name)
      end
    end

    def match(req)
      @routes.find { |route| route.matches?(req) }
    end

    def run(req, res)
      route = match(req)
      route ? route.run(req, res) : res.status = 404
    end

    def display_routes
      @routes.each do |route|
        puts [
          "Action:     #{route.action_name}",
          "Pattern:    #{route.pattern.source}",
          "Controller: #{route.controller_class.name}",
          "Method:     #{route.http_method}",
          '=' * 20
        ].join("\n\r")
      end
    end
  end
end
