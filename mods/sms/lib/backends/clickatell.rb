#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class ::Object
  require "clickatell"
  Clickatell::API.debug_mode = true
end

class Clickatell
  def initialize(config)
    @config = config
  end

  def send_sms(recipient, text)
    api = ::Clickatell::API.authenticate(
      @config["api_key"],
      @config["username"],
      @config["password"])

    begin
      return api.send_message(
        recipient, text)

    rescue ::Clickatell::API::Error => err
      Engines.logger.warn(
        "SMS could not be sent. Clickatell says: %s (code: %s)" %
        [err.message.inspect, err.code])

      return None
    end
  end

  def receive_sms(sender, text)
    raise NotImplementedError
  end
end
