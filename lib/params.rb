require 'uri'

module Monastery
  class Params
    def initialize(req, route_params = {})
      other_params = parse_www_encoded_form("#{req.query_string}#{req.body}")
      @params = route_params.merge(other_params)
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
      params = {}
      URI.decode_www_form(www_encoded_form).each do |key_val_pair|
        keys, value = parse_key(key_val_pair.first), key_val_pair.last
        nested = params

        keys.each_with_index do |key, depth|
          break if depth == keys.length - 1
          nested = nested[key] ||= {}
        end
        nested[keys.last] = value
      end
      params
    end

    def parse_key(key)
      key.split(/\[|\]\[|\]/)
    end
  end
end
