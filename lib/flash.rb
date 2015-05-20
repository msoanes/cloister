require 'json'
require 'webrick'

module Monastery
  class Flash
    def initialize(req)
      session_cookie = req.cookies.find do |cookie|
        cookie.name == cookie_name
      end
      @stale_content = session_cookie ? JSON.parse(session_cookie.value) : {}
      @fresh_content = {}
    end

    def [](key)
      @stale_content[key]
    end

    def []=(key, val)
      @stale_content[key] = @fresh_content[key] = val
    end

    def now
      @stale_content
    end

    def cookie_name
      '_monastery_flash'
    end

    def store_flash(res)
      res.cookies << WEBrick::Cookie.new(cookie_name, @fresh_content.to_json)
    end
  end
end
