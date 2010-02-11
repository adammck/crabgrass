#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

class AddSmsColumnsToUser < ActiveRecord::Migration
  def self.up

    # the user.phone_number field is distinct from the public/private
    # phone number fields (in the profiles), to allow users to receive
    # notifications without disclosing their phone number to *anyone*
    add_column :users, :phone_number,          :string
    add_column :users, :phone_number_verified, :bool
  end

  def self.down
    remove_column :users, :phone_number
    remove_column :users, :phone_number_verified
  end
end
