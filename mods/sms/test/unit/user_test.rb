#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

require File.dirname(__FILE__) + "/../test_helper"


class UserTest < ActiveSupport::TestCase
  fixtures :users

  VALID_PHONE_NUMBER   = "+1-212-111-2222"
  INVALID_PHONE_NUMBER = "123-LOL-WHAT-456"

  def test_mixin_is_working
    assert(users(:blue).respond_to?(:can_receive_sms?),
      "the UserExtension::Sms mixin should be applied to User")
  end

  def test_sms_mod_doesnt_invalidate_existing_users
    assert_valid(users(:blue))
  end

  def test_user_validates_with_valid_phone_number
    u = users(:blue)
    assert_valid(u)

    u.phone_number = VALID_PHONE_NUMBER

    assert_equal(true, u.valid?,
      "User should validate when the User.phone_number field contains a valid "\
      "phone number. Errors were: " + u.errors.inspect)
  end

  def test_user_invalidates_with_invalid_phone_number
    u = users(:blue)
    assert_valid(u)

    u.phone_number = INVALID_PHONE_NUMBER

    assert_equal(false, u.valid?,
      "User should not validate when the User.phone_number field contains an "\
      "invalid phone number")
  end

  def test_user_with_no_phone_number_cant_send_sms
    u = users(:blue)
    assert_nil(u.phone_number)

    assert_equal(nil, u.send_sms("Hello"),
      "the User.send_sms method should return nil when the User.phone_number "\
      "field is empty")
  end

  def test_user_with_invalid_phone_number_cant_send_sms
    u = users(:blue)
    assert_nil(u.phone_number)

    u.phone_number = INVALID_PHONE_NUMBER

    assert_equal(nil, u.send_sms("Hello"),
      "the User.send_sms method should return nil when the User.phone_number "\
      "field is invalid")
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
      "the User.phone_number_verified field should reset to false when "\
      "the User.phone_number field is changed")
  end
end
