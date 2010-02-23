#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class Test
  def initialize(config)
    @config = config
  end

  def send_sms(recipient, text)
    puts "SENDING TEST SMS"
    raise NotImplementedError
  end

  def receive_sms(sender, text)
    puts "RECEIVING TEST SMS"
    raise NotImplementedError
  end
end
