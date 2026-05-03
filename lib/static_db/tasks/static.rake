namespace :static do
  desc "Create fixtures from database; accepts optional path argument"
  task :dump, [:path] => :environment do |t, args|
    if args[:path].blank?
      StaticDb::Dump.new.perform
    else
      StaticDb::Dump.new(fixture_path: Rails.root.join(args[:path])).perform
    end
  end

  desc "Create database from fixtures; accepts optional path argument"
  task :load, [:path] => :environment do |t, args|
    if args[:path].blank?
      StaticDb::Load.new.perform
    else
      StaticDb::Load.new(fixture_path: Rails.root.join(args[:path])).perform
    end
  end
end
