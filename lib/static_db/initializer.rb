# frozen_string_literal: true

require "ostruct"

module StaticDb
  # Configuration and setup utility.  The engine automatically requires this
  # file during Rails initialization, so applications can simply call
  # `StaticDb.configure` from **any** initializer (or even the engine's own
  # initializer).  It behaves exactly like an initializer placed in
  # `config/initializers` of a Rails project.
  #
  # Example usage from a host application:
  #
  #   # config/initializers/static_db.rb
  #   StaticDb.configure do |config|
  #     config.dump_path = Rails.root.join("content", "data")
  #     #
  #     # The rake tasks also accept an explicit path argument which is passed to
  #     # the `StaticDb::Dump`/`Load` constructors; the configuration value is
  #     # used when the argument is omitted.
  #   end
  #
  # The configuration object is a plain OpenStruct and may be extended by
  # the application or other libraries.
  def self.configure
    @config ||= OpenStruct.new
    yield @config if block_given?
    @config.fixture_path ||= Rails.root.join("content", "data")
    @config
  end

  def self.config
    @config || configure
  end
end
