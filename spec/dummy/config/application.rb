require_relative "boot"

require "rails"
require "active_record/railtie"

# Deliberately not `Bundler.require`: the Gemfile has no groups, so that would load
# rubocop and friends into every boot. Requiring the gem after Rails is what
# `Bundler.require` amounts to in a real app.
require "static_db"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    config.eager_load = false
    config.logger = ActiveSupport::Logger.new(IO::NULL)

    # Each spec case is a small app of its own, living in spec/cases/<name>/: its models
    # and migrations are added here, its schema comes in through Rails' own SCHEMA variable.
    if (case_dir = ENV["DUMMY_CASE_DIR"])
      config.paths["app/models"] << File.join(case_dir, "models")
      config.paths["db/migrate"] << File.join(case_dir, "migrate")
    end
  end
end
