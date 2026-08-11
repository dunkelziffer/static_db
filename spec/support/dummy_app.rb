require "fileutils"

# Boots the dummy host application once for the whole suite.
#
# Isolation between examples is truncation, not a transaction: the code under test
# drops and recreates the database from a subprocess, which no transaction survives.
module DummyApp
  INTERNAL_TABLES = %w[schema_migrations ar_internal_metadata sqlite_sequence].freeze

  class << self
    def boot!
      return if @booted

      require_relative "../dummy/config/environment"
      @booted = true

      reset_schema!
    end

    def root = Rails.root

    # Fresh database file, schema loaded in process. Cheap enough to do once per suite.
    def reset_schema!
      ActiveRecord::Base.connection_handler.clear_all_connections!
      FileUtils.rm_f(Dir.glob(root.join("db", "*.sqlite3*")))

      ActiveRecord::Schema.verbose = false
      load root.join("db", "schema.rb")
    end

    # Clears rows and rewinds AUTOINCREMENT so ids restart at 1, which keeps dumped
    # fixture labels stable between examples.
    def truncate!
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        tables = conn.tables - INTERNAL_TABLES

        conn.disable_referential_integrity do
          tables.each { |table| conn.delete("DELETE FROM #{conn.quote_table_name(table)}") }

          # `main.` is load bearing. A temp.sqlite_sequence also exists, unqualified
          # names resolve against temp first, and that one is always empty — so the
          # obvious `DELETE FROM sqlite_sequence` silently does nothing.
          conn.delete("DELETE FROM main.sqlite_sequence") if sequence_table?(conn)
        end
      end
    end

    private

    def sequence_table?(conn)
      conn.select_value("SELECT 1 FROM main.sqlite_master WHERE type = 'table' AND name = 'sqlite_sequence'").present?
    end
  end
end
