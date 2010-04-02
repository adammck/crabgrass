#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

require File.dirname(__FILE__) + "/../test_helper"


class UserTest < ActiveSupport::TestCase
  fixtures :users

  VALID_PHONE_NUMBER   = "+1-212-111-2222"
  INVALID_PHONE_NUMBER = "123-LOL-WHAT-456"
  SHORT_MESSAGE        = "Hello"


  private

  # Return the currently active SMS backend (which should be "test", to
  # avoid actually sending anything while testing).
  def backend
    ::Rails::Plugin::SmsMod::BACKEND
  end


  public

  def test_mixin_is_working
    assert_respond_to users(:blue), :can_receive_sms?
  end


  def test_sms_mod_doesnt_invalidate_existing_users
    assert_valid users(:blue)
  end


  def test_user_phone_number_defaults_to_nil
    assert_nil User.new.phone_number
    assert_nil users(:blue).phone_number
  end


  def test_user_validates_with_valid_phone_number
    user = users(:blue)
    user.phone_number = VALID_PHONE_NUMBER
    assert_valid user
  end


  def test_user_invalidates_with_invalid_phone_number
    user = users(:blue)
    user.phone_number = INVALID_PHONE_NUMBER
    assert_equal false, user.valid?
  end


  def test_user_with_no_phone_number_cant_send_sms
    user = users(:blue)
    assert_nil user.phone_number
    assert_nil user.send_sms SHORT_MESSAGE
  end


  def test_user_with_invalid_phone_number_cant_send_sms
    user = users(:blue)
    user.phone_number = INVALID_PHONE_NUMBER
    assert_nil user.send_sms SHORT_MESSAGE
  end


  def test_verified_field_defaults_to_false
    assert_equal false, User.new.phone_number_verified
  end


  def test_verified_field_resets_when_phone_number_changes
    user = users(:blue)
    user.phone_number_verified = true
    user.phone_number = VALID_PHONE_NUMBER
    user.save

    assert_equal false, user.phone_number_verified
  end


  def test_user_can_send_sms
    user = users(:blue)
    user.phone_number = VALID_PHONE_NUMBER
    user.phone_number_verified = true
    user.save

    # since we have no idea how many messages the mock backend has sent
    # until now, we can only assert that it increases by one during this
    # test. since this could lead to a race-condition (if some other
    # thread were to send a test message), block the other threads.
    Thread.exclusive do
      n = backend.sent.length
      assert user.send_sms SHORT_MESSAGE
      assert_equal n+1, backend.sent.length
      assert_equal backend.sent.last[:recipient], VALID_PHONE_NUMBER
      assert_equal backend.sent.last[:text], SHORT_MESSAGE
    end
  end


  def test_verification_sms_is_sent_when_phone_number_changes
    Thread.exclusive do
      user = users(:blue)
      user.phone_number = VALID_PHONE_NUMBER
      user.save

      # we can't be sure of the exact text (i18n, etc), but the outgoing
      # message must contain the verification code, at least.
      assert backend.sent.last[:text].include?(
        user.pending_verification_code)
    end
  end
end
