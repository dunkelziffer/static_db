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

    # Inserts the rows exactly as they were dumped, one table per file. Unlike Rails fixtures:
    # no ERB, no $LABEL, no generated ids or timestamps, no enum or association lookups, no
    # type casting, and a missing column is NULL instead of the column default.
    def load_data!
      puts green("Loading data ...")

      tables = Dir.glob(@static_db_path.join("*.yml")).sort.to_h do |file|
        [ File.basename(file, ".yml"), read_rows(file) ]
      end

      ActiveRecord::Base.with_connection do |connection|
        connection.transaction do
          connection.disable_referential_integrity do
            tables.each { |table, rows| insert(connection, table, rows) }
          end
        end

        connection.check_all_foreign_keys_valid!
        tables.each_key { |table| connection.reset_pk_sequence!(table) } if connection.respond_to?(:reset_pk_sequence!)
      end

      puts green("Done!")
    end

    def read_rows(file)
      records = YAML.safe_load_file(file, permitted_classes: [ Date, Time ], aliases: true) || {}
      raise "#{file} is not a mapping of labels to records" unless records.is_a?(Hash) && records.values.all?(Hash)

      records.values
    end

    def insert(connection, table, rows)
      columns = connection.columns(table).reject(&:virtual?)
      unknown = rows.flat_map(&:keys).uniq - columns.map(&:name)
      raise "Cannot load #{table}.#{unknown.join(", ")}: no such column, or a generated one" if unknown.any?

      column_list = columns.map { |column| connection.quote_column_name(column.name) }.join(", ")
      rows.each_slice(1000) do |slice|
        values = slice.map { |row| "(#{columns.map { |column| quote(connection, column, row[column.name]) }.join(", ")})" }
        connection.execute("INSERT INTO #{connection.quote_table_name(table)} (#{column_list}) VALUES #{values.join(", ")}")
      end
    end

    def quote(connection, column, value)
      value = ActiveModel::Type::Binary::Data.new(value) if column.type == :binary && value.is_a?(String)
      connection.quote(value)
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end
  end
end
