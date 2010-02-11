#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

module UserExtension
  module Sms
    def self.add_to_class_definition
      lambda do

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

      private

      def verify_new_phone_number
        if self.phone_number_changed?
          self.phone_number_verified = false
        end

        true
      end
    end
  end
end
