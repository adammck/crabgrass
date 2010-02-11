#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

Dispatcher.to_prepare do
  apply_mixin_to_model(User, UserExtension::Sms)
  require 'sms_listener'
end
