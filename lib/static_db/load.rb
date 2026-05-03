module StaticDb
  class Load

    attr_reader :fixture_path

    def initialize(fixture_path: StaticDb.config.fixture_path)
      @fixture_path = Pathname.new(fixture_path)
    end

    def perform
      puts green("Loading fixtures ...")
      system("bin/rails", "db:drop", "db:create", "db:schema:load")
      load_fixtures!
      puts green("Done!")
    rescue => e
      puts red("Failed to load fixtures: #{e.message}")
      puts red("Exiting and skipping active_fixtures:dump!")
      $skip_active_fixtures_dump = true
      exit 1
    end

    private

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
