# Many apps touch the database while booting: settings, feature flags, a table_exists?
# check. DUMMY_QUERY_DATABASE_AT_BOOT reproduces that, and keeps the connection leased.
if ENV["DUMMY_QUERY_DATABASE_AT_BOOT"]
  ActiveRecord::Base.lease_connection.select_value("SELECT 1")
end
