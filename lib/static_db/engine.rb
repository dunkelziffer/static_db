require "static_db/configurable"

module StaticDb # :nodoc:
  # Engines are required very early in the Rails boot sequence via
  # `Bundler.require(*Rails.groups)` in `application.rb`.

  # Thus, the config is available before:
  # - the rest of `application.rb`
  # - `environment/*.rb`
  # - the engines `initializer` block gets executed
  # - regular initializers from `config/initializers/`
  include StaticDb::Configurable

  config_accessor :static_db_path, instance_accessor: false, default: -> { Rails.root.join("content", "data") }
  config_accessor :load, instance_accessor: false, default: false
  config_accessor :dump, instance_accessor: false, default: false

  def self.unproc(value_or_proc)
    value_or_proc.respond_to?(:call) ? value_or_proc.call : value_or_proc
  end

  def self.path = unproc(config.static_db_path)
  def self.load? = unproc(config.load)
  def self.dump? = unproc(config.dump)

  def self.parklife?
    File.basename($PROGRAM_NAME) == "parklife" && ARGV.first == "build"
  end

  class Engine < ::Rails::Engine # :nodoc:
    isolate_namespace StaticDb

    rake_tasks do
      load File.expand_path("./tasks/static.rake", __dir__)
    end

    initializer "static_db.configure" do |app|
      if defined?(Rails::Server) || defined?(Rails::Console) || StaticDb.parklife?
        Rails.application.config.after_initialize do
          StaticDb::Load.new.perform if StaticDb.load?
        end

        at_exit do
          StaticDb::Dump.new.perform if StaticDb.dump?
        end
      end
    end
  end
end
