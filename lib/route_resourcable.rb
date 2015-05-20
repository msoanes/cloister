module Monastery
  module RouteResourcable
    DEFAULT_ROUTES = [
      { pattern: '/new',            method: 'get',    action: :new },
      { pattern: '',                method: 'post',   action: :create },
      { pattern: '',                method: 'get',    action: :index },
      { pattern: '\/(?<id>.*)',      method: 'get',    action: :show },
      { pattern: '\/(?<id>.*)/edit', method: 'get',    action: :edit },
      { pattern: '\/(?<id>.*)',      method: 'patch',  action: :update },
      { pattern: '\/(?<id>.*)',      method: 'put',    action: :update },
      { pattern: '\/(?<id>.*)',      method: 'delete', action: :destroy }
    ]

    def default_routes
      DEFAULT_ROUTES
    end

    def resources(controller_class, options = nil)
      default_routes.each do |opts|
        add_route(
          Regexp.new("#{controller_class.controller_name}#{opts[:pattern]}"),
          opts[:method],
          controller_class,
          opts[:action]
        )
      end
    end
  end
end
