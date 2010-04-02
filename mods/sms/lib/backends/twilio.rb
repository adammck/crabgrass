#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class ::Object
  require "twiliolib"
end

class Twilio
  API_VERSION = "2008-08-01"

  def initialize(config)
    @config = config
    @account = ::Twilio::RestAccount.new(
      @config["account_sid"],
      @config["auth_token"])
  end

  def rest_url
    "/#{API_VERSION}/Accounts/#{@config["account_sid"]}/SMS/Messages"
  end

  def send_sms(recipient, text)
    r = @account.request(rest_url, "POST", {
      "From" => @config["origin_number"],
      "To"   => recipient,
      "Body" => text
    })

    return r.kind_of? Net::HTTPSuccess
  end

  def receive_sms(sender, text)
    raise NotImplementedError
  end
end
