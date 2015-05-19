require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      session_cookie = req.cookies.find do |cookie|
        cookie.name == cookie_name
      end
      if session_cookie
        @content = JSON.parse(session_cookie.value)
      else
        @content = {}
      end
    end

    def [](key)
      @content[key]
    end

    def []=(key, val)
      @content[key] = val
    end

    def cookie_name
      '_rails_lite_app'
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies << WEBrick::Cookie.new(cookie_name, @content.to_json)
    end
  end
end
