require "pathname"

# Canonical, comparable views of the two things the gem round-trips.
#
# The database snapshot deliberately reads at the adapter level: no models, no type
# casting, no default scopes. Comparing through ActiveRecord would silently cast away
# exactly the drift these specs exist to catch.
module DbSnapshot
  def db_snapshot
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      tables = conn.tables.sort - DummyApp::INTERNAL_TABLES

      tables.index_with do |table|
        conn.select_all("SELECT * FROM #{conn.quote_table_name(table)}#{order_clause(conn, table)}").to_a
      end
    end
  end

  # Byte-level, because these files get committed: requoting a string or reordering
  # keys is a real defect even when the parsed YAML is equivalent.
  def dir_snapshot(dir)
    dir = Pathname.new(dir)
    return {} unless dir.directory?

    dir.children.select(&:file?).sort.to_h { |file| [ file.basename.to_s, file.binread ] }
  end

  private

  def order_clause(conn, table)
    keys = Array(conn.primary_key(table))
    return "" if keys.empty?

    " ORDER BY #{keys.map { |key| conn.quote_column_name(key) }.join(", ")}"
  end
end

RSpec.configure { |config| config.include DbSnapshot }
