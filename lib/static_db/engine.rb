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

  config_accessor :fixture_path, instance_accessor: false, default: -> { Rails.root.join("content", "data") }

  class Engine < ::Rails::Engine # :nodoc:
    isolate_namespace StaticDb

    rake_tasks do
      load File.expand_path("./tasks/static.rake", __dir__)
    end

    initializer "static_db.configure" do |app|
      if defined?(Rails::Server) || defined?(Rails::Console) || ARGV.first == "build"
        Rails.application.config.after_initialize do
          StaticDb::Load.new.perform
        end

        at_exit do
          StaticDb::Dump.new.perform
        end
      end
    end

  end
end
