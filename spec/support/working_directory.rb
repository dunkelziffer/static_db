RSpec.configure do |config|
  # A real Rails process runs with its working directory at Rails.root — that is what
  # makes the relative `bin/rails` in StaticDb::Load#reset_database! resolve. rspec runs
  # from the gem root, so without this the reset silently finds no bin/rails, `system`
  # returns nil, and the specs quietly stop exercising what users actually run.
  config.around { |example| Dir.chdir(DummyApp.root) { example.run } }
end
