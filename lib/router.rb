require_relative 'route'
require_relative 'route_resourcable'

module Monastery
  class Router
    include RouteResourcable
    attr_reader :routes, :named_paths

    def self.regex_from_pattern_string(pattern_string)
      re_pattern = pattern_string.split('/').map do |part|
        part.gsub(/:(.+)[\/]{,1}/, '(?<\1>\d+)')
      end.join('/')

      Regexp.new("^/#{re_pattern}\/?$")
    end

    def initialize
      @routes = []
      @named_paths = {}
    end

    def add_route(pattern, method, controller_class, action_name, name = nil)
      regex_pattern = self.class.regex_from_pattern_string(pattern)
      name ||= "#{controller_class.controller_name}_#{action_name}"
      @routes << Route.new(regex_pattern, method, controller_class, action_name)
      @named_paths[name] = pattern
    end

    def method_missing(method_name, *args, &prc)
      if method_name.to_s[-5..-1] == '_path'
        find_path(method_name.to_s[0...-5], *args)
      else
        super
      end
    end

    def find_path(path_name, *args)
      path = named_paths[path_name]
      passed_fixnums = args.all? { |arg| arg.is_a?(Fixnum) }
      subbed_path = path.gsub(/:([^\/]+)/) do
        args.shift
      end
      args.empty? ? subbed_path : raise(ArgumentError.new('Too many args'))
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
      route ? route.run(req, res, @named_paths) : res.status = 404
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
