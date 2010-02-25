#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class Twilio
  def initialize(config)
    @config = config
  end

  def send_sms(recipient, text)
    raise NotImplementedError
  end

  def receive_sms(sender, text)
    raise NotImplementedError
  end
end
