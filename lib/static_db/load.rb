module StaticDb
  class Load
    def initialize(static_db_path: StaticDb.path)
      @static_db_path = Pathname.new(static_db_path)
    end

    def perform
      reset_database!
      load_data!
    rescue => e
      puts red("Failed to load data: #{e.message}")
      puts red("Exiting and skipping StaticDb::Dump.")
      $skip_static_db_dump = true
      exit 1
    end

    private

    def reset_database!
      puts green("Resetting database ...")

      system("bin/rails", "db:drop", "db:create", "db:schema:load")

      puts green("Done!")
    end

    def load_data!
      puts green("Loading data ...")

      base_names = Dir.glob(File.join(@static_db_path, "*.yml")).map do |file|
        File.basename(file, ".*")
      end
      ActiveRecord::FixtureSet.create_fixtures(@static_db_path, base_names)

      puts green("Done!")
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end
  end
end
