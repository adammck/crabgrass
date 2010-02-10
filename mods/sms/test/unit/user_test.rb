require File.dirname(__FILE__) + "/../test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def test_mixin_is_working
    assert(users(:blue).respond_to?(:can_receive_sms?),
      "the UserExtension::Sms mixin should be applied to User")
  end

  def test_verified_field_defaults_to_false
    assert_equal(false, User.new.phone_number_verified,
      "the User.phone_number_verified field should default to false")
  end

  def test_verified_field_resets_when_phone_number_changes
    user = User.new

    user.update_attributes(:phone_number_verified => true)
    user.update_attributes(:phone_number => "12345")

    assert_equal(false, user.phone_number_verified,
      "The User.phone_number_verified field should reset to false when "\
      "the User.phone_number field is changed")
  end
end
