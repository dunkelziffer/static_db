RSpec.configure do |config|
  # Truncation, not a transaction: the code under test drops and recreates the database
  # from a subprocess, which no transaction would survive.
  config.before { DummyApp.truncate! }

  # `FixtureSet.create_fixtures` memoises per connection and fixture-set name, so the
  # second load in a process is a no-op. Without this, every example after the first
  # would insert nothing and pass anyway.
  config.before { ActiveRecord::FixtureSet.reset_cache }
end
