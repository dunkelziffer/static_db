require "fileutils"
require "tmpdir"

# One case's app from spec/cases/<name>/ (schema, models, factories, migrations), plus
# throwaway state: a database directory, the data directory static_db reads and writes,
# and the directory Active Storage keeps its files in.
class Workspace
  CASES = Pathname(__dir__).join("..", "cases").expand_path

  # All records are created at this instant, so dumps are byte-for-byte reproducible.
  ARRANGED_AT = Time.utc(2026, 3, 14, 9, 26, 53, 589_793)

  attr_reader :case_dir, :root

  def self.for(name) = new(CASES.join(name))

  def initialize(case_dir)
    @case_dir = Pathname(case_dir)
    @root = Pathname(Dir.mktmpdir("static_db-#{@case_dir.basename}-"))
    data_dir.mkpath
    db_dir.mkpath
    # A copy, because `db:migrate` rewrites the schema it was given.
    FileUtils.cp(@case_dir.join("schema.rb"), schema_path)
  end

  def data_dir = root.join("data")
  def db_dir = root.join("db")
  def storage_dir = root.join("storage")
  def schema_path = root.join("schema.rb")
  def golden_dir = case_dir.join("golden")

  def env(overrides = {})
    {
      "RAILS_ENV" => "development",
      "STATIC_DB" => "off",
      "SCHEMA" => schema_path.to_s,
      "DUMMY_CASE_DIR" => case_dir.to_s,
      "DUMMY_DATA_DIR" => data_dir.to_s,
      "DUMMY_DB_DIR" => db_dir.to_s,
      "DUMMY_STORAGE_DIR" => storage_dir.to_s
    }.merge(overrides)
  end

  # Creates the database from the case's schema and runs the block with FactoryBot at
  # ARRANGED_AT. Returns a snapshot of what ended up stored.
  def arrange(env: {}, &block)
    factories = case_dir.join("factories").to_s

    DummyApp.in_booted_app(self.env(env)) do
      ActiveRecord::Schema.verbose = false
      load ENV.fetch("SCHEMA")
      Arrangement.run(factories, &block)
      Snapshot.database
    end
  end

  # Changes an existing database, e.g. between two sessions.
  def change(env: {}, &block)
    factories = case_dir.join("factories").to_s
    DummyApp.in_booted_app(self.env(env)) do
      Arrangement.run(factories, &block)
      nil # The block's records are instances of models the spec process does not have.
    end
  end

  def snapshot(env: {}) = DummyApp.in_booted_app(self.env(env)) { Snapshot.database }

  # A `bin/rails console` session: the load hook fires at boot, the dump hook at exit.
  def console(static_db:, input: "", env: {})
    DummyApp.run("bin/rails", "console", env: self.env("STATIC_DB" => static_db, **env), input:)
  end

  def rails(*args, env: {}) = DummyApp.run("bin/rails", *args, env: self.env(env))

  def parklife(*args, static_db:, env: {})
    DummyApp.run("bin/parklife", *args, env: self.env("STATIC_DB" => static_db, **env))
  end

  def files = Snapshot.files(data_dir)

  def cleanup = FileUtils.rm_rf(root)
end

# What a case's setup block runs in: FactoryBot with the case's factories, frozen time,
# and `execute` for raw SQL that ActiveRecord would not produce. Runs in a booted app.
module Arrangement
  def self.run(factories, &block)
    require "factory_bot"
    require "active_support/testing/time_helpers"

    FactoryBot.definition_file_paths = [ factories ]
    FactoryBot.find_definitions

    context = Object.new
    context.extend(FactoryBot::Syntax::Methods, ActiveSupport::Testing::TimeHelpers, self)
    context.travel_to(Workspace::ARRANGED_AT, with_usec: true) { context.instance_exec(&block) }
  end

  def execute(sql) = ActiveRecord::Base.with_connection { |conn| conn.execute(sql) }
end

RSpec.configure do |config|
  config.include(Module.new do
    def workspace(name) = (@workspaces ||= []).push(Workspace.for(name)).last
  end)

  config.after { @workspaces&.each(&:cleanup) }
end
