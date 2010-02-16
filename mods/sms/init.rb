#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

require "clickatell"
Clickatell::API.debug_mode = true

module ::SmsMod
  conf_filename = RAILS_ROOT + "/config/clickatell.yml"
  CLICKATELL_CONFIG = YAML.load_file(conf_filename)
end

Dispatcher.to_prepare do
  apply_mixin_to_model(User, UserExtension::Sms)
  require 'sms_listener'
end
