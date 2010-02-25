#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

require File.dirname(__FILE__) + "/../test_helper"


class UserTest < ActiveSupport::TestCase
  fixtures :users

  VALID_PHONE_NUMBER   = "+1-212-111-2222"
  INVALID_PHONE_NUMBER = "12345"

  def test_mixin_is_working
    assert(users(:blue).respond_to?(:can_receive_sms?),
      "the UserExtension::Sms mixin should be applied to User")
  end

  def test_user_with_no_phone_number_cant_send_sms
    user = User.new(:phone_number => VALID_PHONE_NUMBER)
    assert_equal(nil, user.send_sms("Hello"),
      "the User.send_sms method should return nil when the User.phone_number "\
      "field is empty")
  end

  def test_user_accepts_valid_phone_number
    assert_nothing_raised do
      User.new(:phone_number => VALID_PHONE_NUMBER).save
    end
  end

  def test_user_rejects_invalid_phone_number
    assert_raise do
      User.new(:phone_number => INVALID_PHONE_NUMBER).save
    end
  end

  def test_verified_field_defaults_to_false
    assert_equal(false, User.new.phone_number_verified,
      "the User.phone_number_verified field should default to false")
  end

  def test_verified_field_resets_when_phone_number_changes
    user = User.new

    user.update_attributes(:phone_number_verified => true)
    user.update_attributes(:phone_number => VALID_PHONE_NUMBER)

    assert_equal(false, user.phone_number_verified,
      "The User.phone_number_verified field should reset to false when "\
      "the User.phone_number field is changed")
  end
end
