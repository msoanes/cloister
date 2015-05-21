require 'active_support/inflector'

module Monastery
  module RouteResourcable
    PATTERNS = {
      index: '',
      new: '/new',
      show: '/:id',
      edit: '/:id/edit'
    }
    DEFAULT_ROUTES = [
      { pattern: :new,   method: 'get',    action: :new },
      { pattern: :index, method: 'post',   action: :create },
      { pattern: :index, method: 'get',    action: :index },
      { pattern: :show,  method: 'get',    action: :show },
      { pattern: :edit,  method: 'get',    action: :edit },
      { pattern: :show,  method: 'patch',  action: :update },
      { pattern: :show,  method: 'put',    action: :update },
      { pattern: :show,  method: 'delete', action: :destroy }
    ]

    def default_routes
      DEFAULT_ROUTES
    end

    def resources(controller_sym, options = nil)
      default_routes.each do |opts|
        controller_class = "#{controller_sym}_controller".camelcase.constantize
        pattern_string = "#{controller_sym}#{PATTERNS[opts[:pattern]]}"
        path_name = find_path_name(opts[:pattern], controller_sym)
        add_route(
          pattern_string,
          opts[:method],
          controller_class,
          opts[:action],
          path_name
        )
      end
    end

    def find_path_name(pattern, controller_sym)
      case pattern
      when :index
        controller_sym.to_s
      when :new
        "new_#{controller_sym.to_s.singularize}"
      when :show
        "#{controller_sym.to_s.singularize}"
      when :edit
        "edit_#{controller_sym.to_s.singularize}"
      end
    end
  end
end
