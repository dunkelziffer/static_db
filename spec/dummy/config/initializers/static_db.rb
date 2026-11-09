# The example initializer from the README, with the data directory supplied by the spec
# workspace. DUMMY_UNCONFIGURED skips it, leaving static_db at the gem's defaults.
unless ENV["DUMMY_UNCONFIGURED"]
  StaticDb.configure do |config|
    config.static_db_path = ENV.fetch("DUMMY_DATA_DIR")

    config.load = ENV["STATIC_DB"].in? [ "load", nil, "on", "true", "1" ]
    config.dump = ENV["STATIC_DB"].in? [ "dump", nil, "on", "true", "1" ]
  end
end
