#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class Test
  attr_reader :sent, :received

  def initialize(config)
    @config = config
    @sent = []
    @received = []
  end

  def send_sms(recipient, text)
    @sent.push [recipient, text]
    return true
  end

  def receive_sms(sender, text)
    puts "RECEIVING TEST SMS"
    raise NotImplementedError
  end
end
