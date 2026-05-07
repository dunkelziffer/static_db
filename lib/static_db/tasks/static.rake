namespace :static do
  desc "Reset database and load YAML fixtures"
  task :load, [ :static_db_path ] => :environment do |t, args|
    if args[:static_db_path].blank?
      StaticDb::Load.new.perform
    else
      StaticDb::Load.new(static_db_path: Rails.root.join(args[:static_db_path])).perform
    end
  end

  desc "Dump database to YAML fixtures"
  task :dump, [ :static_db_path ] => :environment do |t, args|
    if args[:static_db_path].blank?
      StaticDb::Dump.new.perform
    else
      StaticDb::Dump.new(static_db_path: Rails.root.join(args[:static_db_path])).perform
    end
  end
end
