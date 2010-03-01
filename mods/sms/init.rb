#!/usr/bin/env ruby
# vim: et ts=2 sts=2 sw=2

module SmsMod
  module Backend

    # Load a backend source file by name.
    def self.load_backend_rb(file_name)

      # wouldn't it be easier to just "require" the file? of course it
      # would. but since rails engines loads mods (including this file)
      # into the Rails::Plugin module (the same way; i stole this from
      # vendor/plugins/engines/lib/engines/rails_extensions/routing.rb)
      # we must do the same to the backends, to make them visible here,
      # without fully qualifiying the names or other hackery.
      file_path = RAILS_ROOT + "/mods/sms/lib/backends/#{file_name}.rb"
      eval(IO.read(file_path), binding, file_path)
    end
  end


  private


  # Return the configuration (a hash) for the current environment.
  def self.load_config
    conf_filename = RAILS_ROOT + "/config/sms.yml"
    return YAML.load_file(conf_filename)[Rails.env]
  end

  # Return an instance of the SMS backend for *config*. The class of the
  # backend is specified by the "backend" key (similar to the "adaptor"
  # key in the database configuration).
  def self.spawn_backend(config)
    file_name = config["backend"]
    klass_name = file_name.capitalize

    # load the backend source
    Backend.load_backend_rb(file_name)

    # if the backend doesn't exist, raise a specific error, since it's
    # almost certainly a problem with the configuration.
    # --
    # we're checking explicitly, rather than trying Backend.const_get
    # and catching the NameError, because backends are often named the
    # same as their global API helpers (eg. Clickatell). These helpers
    # are available everywhere, resulting in all sorts of names working
    # via Backend.const_get, which aren't actually backends.
    unless Backend.constants.include?(klass_name)
      raise ::NameError.new(
        "invalid backend %s" %
        klass_name.inspect)
    end

    # instantiate and return the backend
    klass = Backend.const_get(klass_name)
    return klass.new(config)
  end
end


Dispatcher.to_prepare do
  apply_mixin_to_model(User, UserExtension::Sms)
  require "sms_listener"

  module SmsMod
    config  = load_config
    BACKEND = spawn_backend(config)
  end
end
