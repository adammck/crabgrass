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

      def send_sms(text)
        return None unless\
          phone_number

        conf = SmsMod::CLICKATELL_CONFIG
        api = Clickatell::API.authenticate(
          conf["api_key"], conf["username"], conf["password"])

        begin
          api.send_message(
            phone_number, text)

        # the message couldn't be sent
        rescue Clickatell::API::Error => err

          Engines.logger.warn(
            "SMS could not be sent. Clickatell Says: %s (code: %s)" %
            [err.message.inspect, err.code])

          # Error 114: "Cannot route message"
          # the number is probably invalid
          if err.code == 114
          end

          return nil
        end
      end

      private

      def verify_new_phone_number
        if phone_number_changed?
          @phone_number_verified = false
          send_sms("Test from Crabgrass")
        end

        true
      end
    end
  end
end
