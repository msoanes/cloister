require 'json'
require 'webrick'

module Monastery
  class Session
    def initialize(req)
      session_cookie = req.cookies.find do |cookie|
        cookie.name == cookie_name
      end
      @content = session_cookie ? JSON.parse(session_cookie.value) : {}
    end

    def [](key)
      @content[key]
    end

    def []=(key, val)
      @content[key] = val
    end

    def cookie_name
      '_monastery_app'
    end

    def store_session(res)
      res.cookies << WEBrick::Cookie.new(cookie_name, @content.to_json)
    end
  end
end
