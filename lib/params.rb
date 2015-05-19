require 'uri'

module Monastery
  class Params
    def initialize(req, route_params = {})
      @params = route_params
      parse_www_encoded_form(req.query_string.to_s)
      parse_www_encoded_form(req.body.to_s)
    end

    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private

    def parse_www_encoded_form(www_encoded_form)
      URI.decode_www_form(www_encoded_form).each do |key_val_pair|
        keys, value = parse_key(key_val_pair.first), key_val_pair.last
        max_depth = keys.length - 1
        nested = @params

        keys.each_with_index do |key, depth|
          break if depth == max_depth
          nested = nested[key] ||= {}
        end
        nested[keys.last] = value
      end
    end

    def parse_key(key)
      key.split(/\[|\]\[|\]/)
    end
  end
end
