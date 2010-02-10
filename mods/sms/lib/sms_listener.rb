#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class SmsListener < Crabgrass::Hook::ViewListener
  include Singleton

  def html_head(context)
    stylesheet_link_tag "sms", :plugin => "sms"
  end

  def user_edit_form__after_email(context)
    render :partial => "/sms/phone_number_form", :locals => context
  end

  def user_edit_form__after_receive_notifications(context)
    render :partial => "/sms/notifications_form"
  end
end
