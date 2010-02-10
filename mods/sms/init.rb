Dispatcher.to_prepare do
  apply_mixin_to_model(User, UserExtension::Sms)
  require 'sms_listener'
end
