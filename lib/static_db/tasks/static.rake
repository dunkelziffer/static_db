namespace :static do
  desc "Create fixtures from database; accepts optional path argument"
  task :dump, [:path] => :environment do |t, args|
    path = if args[:path].blank?
      StaticDb.config.fixture_path
    else
      Rails.root.join(args[:path])
    end

    StaticDb::Dump.new(fixture_path: path).perform
  end

  desc "Create database from fixtures; accepts optional path argument"
  task :load, [:path] => :environment do |t, args|
    path = if args[:path].blank?
      StaticDb.config.fixture_path
    else
      Rails.root.join(args[:path])
    end

    StaticDb::Load.new(fixture_path: path).perform
  end
end
