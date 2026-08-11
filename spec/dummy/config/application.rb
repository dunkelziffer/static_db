require_relative "boot"

require "rails"
require "active_record/railtie"

# Deliberately not `Bundler.require`: the Gemfile has no group blocks, so that would
# pull rubocop and friends into every spec run. The engine registers itself as soon as
# `static_db` is loaded with `Rails::Railtie` already defined.
require "static_db"

module Dummy
  class Application < Rails::Application
    # Tracks whichever Rails the matrix is currently running, so this app boots
    # unchanged on every version the gemspec allows.
    config.load_defaults Rails::VERSION::STRING.to_f

    config.eager_load = false
    config.logger = ActiveSupport::Logger.new(IO::NULL)
    config.active_support.report_deprecations = true
  end
end
