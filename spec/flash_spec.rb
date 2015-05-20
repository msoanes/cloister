require 'webrick'
require 'flash'
require 'controller_base'

describe Monastery::Flash do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:flash) { WEBrick::Cookie.new('_monastery_flash', { abc: 'def' }.to_json) }

  it "deserializes json cookie if one exists" do
    req.cookies << flash
    flash = Monastery::Flash.new(req)
    expect(flash['abc']).to eq('def')
  end

  describe "#store_flash" do
    context "without cookies in request" do
      before(:each) do
        flash = Monastery::Flash.new(req)
        flash['first_key'] = 'first_val'
        flash.store_flash(res)
      end

      it "adds new cookie with '_monastery_flash' name to response" do
        cookie = res.cookies.find { |c| c.name == '_monastery_flash' }
        expect(cookie).not_to be_nil
      end

      it "stores the cookie in json format" do
        cookie = res.cookies.find { |c| c.name == '_monastery_flash' }
        expect(JSON.parse(cookie.value)).to be_instance_of(Hash)
      end
    end

    context "with cookies in request" do
      before(:each) do
        flash = WEBrick::Cookie.new('_monastery_flash', { pho: "soup" }.to_json)
        req.cookies << flash
      end

      it "reads the pre-existing cookie data into hash" do
        flash = Monastery::Flash.new(req)
        expect(flash['pho']).to eq('soup')
      end

      it "saves only new data to the cookie" do
        flash = Monastery::Flash.new(req)
        flash['machine'] = 'mocha'
        flash.store_flash(res)
        cookie = res.cookies.find { |c| c.name == '_monastery_flash' }
        h = JSON.parse(cookie.value)
        expect(h['pho']).to be_nil
        expect(h['machine']).to eq('mocha')
      end

      it "doesn't save data passed to flash.now" do
        flash = Monastery::Flash.new(req)
        flash.now['machine'] = 'mocha'
        expect(flash['machine']).to eq('mocha')
        flash.store_flash(res)
        cookie = res.cookies.find { |c| c.name == '_monastery_flash' }
        h = JSON.parse(cookie.value)
        expect(h['pho']).to be_nil
        expect(h['machine']).to be_nil
      end
    end

  end
end
