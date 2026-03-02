# frozen_string_literal: true

require "static_db/initializer"

module StaticDb # :nodoc:
  class Engine < ::Rails::Engine # :nodoc:
    isolate_namespace StaticDb

    rake_tasks do
      load File.expand_path("./tasks/static.rake", __dir__)
    end

    initializer "static_db.configure" do |app|
      if defined?(Rails::Server) || defined?(Rails::Console) || ARGV.first == "build"
        Rails.application.config.after_initialize do
          unless Object.const_defined?("Rake::Task") && Rake::Task.task_defined?("static:load")
            Rails.application.load_tasks
          end

          Rake::Task["static:load"].invoke
        end

        at_exit do
          unless Object.const_defined?("Rake::Task") && Rake::Task.task_defined?("static:dump")
            Rails.application.load_tasks
          end

          Rake::Task["static:dump"].invoke
        end
      end
    end

  end
end
