#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

module UserExtension
  module Sms
    def self.add_to_class_definition
      lambda do

        # perform some very loose validation of the phone number field
        # before saving it. the backend will do it properly when we try
        # to send an sms. (but it's too late, by then!)
        validates_format_of(
          :phone_number,
          :allow_blank => true,
          :with        => /\A(\+[\d\-]+)\Z/i,
          :message     => "is not a valid phone number")

        # protect the :phone_number_verified field, to prevent sneaky
        # users from skipping verification by POSTing it to /user/save
        attr_protected :phone_number_verified

        # when the user's phone number changes, we must mark it as
        # un-verified, and send out an sms to confirm it's theirs
        before_save :verify_new_phone_number
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def can_receive_sms?
        false
      end

      def send_sms(text)
        valid?

        # abort if phone_number appears to be empty or invalid. even
        # though the backend might accept it anyway, we want all stored
        # numbers to be strictly validated, to ensure they're routed
        return nil if errors.on(:phone_number)
        return nil unless phone_number

        return ::Rails::Plugin::SmsMod::BACKEND.send_sms(
            phone_number,
            text)
      end

      private

      def generate_phone_number_verification_code(length=4)

        # only use easily distinguishable characters in verification
        # codes (i removed <0OQ>, <1i>, <4A>, <5S>, <8B>, <UV> from the
        # usual A-Z + 0-9, and avoided lower-case altogether)
        chars = %w"2 3 6 7 9 C D E F G H J K L M N P Q R T W X Y Z"

        # rather than generating the string _truly_ randomly, shuffle
        # the order of the characters and pluck out the first *length*
        # of them (to avoid duplicate characters)
        chars.sort_by { rand }[0, length].join
      end

      def verify_new_phone_number
        if phone_number_changed?
          @phone_number_verified = false
          send_sms(
            "To verify your phone number, please respond: %s" %
            generate_phone_number_verification_code)
        end

        # we must return true, to avoid cancelling the save. we're not
        # actually validating anything here, just resetting the flag
        true
      end
    end
  end
end
