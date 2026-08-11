begin
  require "debug" unless ENV["CI"]
rescue LoadError
end
ENV["RAILS_ENV"] = "test"

require "tmpdir"

# Deliberately no `require "static_db"` here. `lib/static_db.rb` only loads the engine
# when `Rails::Railtie` is already defined, so requiring it before Rails would silently
# give us a StaticDb with no engine, no config and no hooks — and the second require
# from the dummy app would be a no-op. The app requires it in the right order.
require_relative "support/dummy_app"
DummyApp.boot!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run_when_matching :focus

  config.order = :random
  Kernel.srand config.seed
end
