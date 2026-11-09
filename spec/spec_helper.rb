begin
  require "debug" unless ENV["CI"]
rescue LoadError
end

# The spec process never boots Rails. static_db hooks into the boot sequence, resets the
# database from a subprocess and exits on failure, so every step runs the dummy app in a
# process of its own, the way users run it. See spec/support/dummy_app.rb.
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
