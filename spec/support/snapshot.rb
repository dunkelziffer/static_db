require "pathname"

# Comparable views of the two things static_db round-trips.
module Snapshot
  # Binary strings get a type of their own, so a BLOB that comes back as TEXT with the
  # same bytes does not compare equal.
  Binary = Data.define(:bytes) do
    def inspect = "#<binary #{bytes.unpack1("H*")}>"
  end

  INTERNAL_TABLES = %w[ar_internal_metadata schema_migrations].freeze

  module_function

  # Every table and row as the adapter returns them: no models, no type casting, no
  # default scopes. Must run inside a booted app.
  def database
    ActiveRecord::Base.with_connection do |conn|
      (conn.tables - INTERNAL_TABLES).sort.to_h do |table|
        rows = conn.select_all("SELECT * FROM #{conn.quote_table_name(table)} ORDER BY #{order(conn, table)}")
        [ table, rows.map { |row| row.transform_values { |value| tag(value) } } ]
      end
    end
  end

  # File name => bytes. Byte level, because these files get committed: a requoted string
  # is a diff in git even when the parsed YAML is equal.
  def files(dir)
    dir = Pathname(dir)
    return {} unless dir.directory?

    dir.children.select(&:file?).sort.to_h { |file| [ file.basename.to_s, file.binread ] }
  end

  def order(conn, table)
    columns = Array(conn.primary_key(table))
    columns = conn.columns(table).map(&:name) if columns.empty?
    columns.map { |column| conn.quote_column_name(column) }.join(", ")
  end

  def tag(value)
    value.is_a?(String) && value.encoding == Encoding::BINARY ? Binary.new(value) : value
  end
end
