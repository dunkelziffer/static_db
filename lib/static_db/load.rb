# frozen_string_literal: true

module StaticDb
  class Load

    attr_reader :fixture_path

    def initialize(fixture_path:)
      @fixture_path = Pathname.new(fixture_path)
    end

    def perform
      puts green("Loading fixtures ...")

      reenable_rake_tasks!
      Rake::Task["db:create"].invoke
      Rake::Task["db:schema:load"].invoke
      load_fixtures!

      puts green("Done!")
    rescue => e
      puts red("Failed to load fixtures: #{e.message}")
      puts red("Exiting and skipping active_fixtures:dump!")
      $skip_active_fixtures_dump = true
      exit 1
    end

    private

    def reenable_rake_tasks!
      ["db:create", "db:schema:load"].each do |task_name|
        Rake::Task[task_name].reenable
      end
    end

    def load_fixtures!
      base_names = Dir.glob(File.join(fixture_path, "*.yml")).map do |file|
        File.basename(file, ".*")
      end

      ActiveRecord::FixtureSet.create_fixtures(fixture_path, base_names)
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end

  end
end
