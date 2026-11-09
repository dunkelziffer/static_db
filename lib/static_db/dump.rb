module StaticDb
  class Dump
    # A table's rows as the database returns them, ordered by primary key, or by all
    # columns for a table without one.
    Table = Data.define(:name, :primary_key, :columns, :rows)

    def initialize(static_db_path: StaticDb.path)
      @static_db_path = Pathname.new(static_db_path)
    end

    def perform
      exit 1 if $skip_static_db_dump

      tables = ActiveRecord::Base.with_connection { |connection| read_tables(connection) }
      validate_records!(tables)
      reset_data_directory!
      dump_data!(tables)
    end

    private

    # Every table, except Rails' own and empty ones.
    def read_tables(connection)
      (connection.tables - internal_tables).sort.filter_map do |name|
        primary_key = connection.primary_keys(name)
        columns = dumped_columns(connection.columns(name), primary_key)
        order = (primary_key.presence || columns.map(&:name)).map { |column| connection.quote_column_name(column) }
        rows = connection.select_all("SELECT * FROM #{connection.quote_table_name(name)} ORDER BY #{order.join(", ")}").to_a

        Table.new(name:, primary_key:, columns:, rows:) if rows.any?
      end
    end

    def internal_tables
      base = ActiveRecord::Base
      [ base.schema_migrations_table_name, base.internal_metadata_table_name ].map do |name|
        "#{base.table_name_prefix}#{name}#{base.table_name_suffix}"
      end
    end

    # Generated columns are left out: the database computes them and refuses values for them.
    # Primary key columns come first, in the key's order, then the others alphabetically, so
    # the order does not depend on when a migration added a column.
    def dumped_columns(columns, primary_key)
      columns.reject(&:virtual?).sort_by { |column| [ primary_key.index(column.name) || primary_key.size, column.name ] }
    end

    def validate_records!(tables)
      puts green("Validating records ...")

      Rails.application.eager_load!
      errors = tables.flat_map { |table| validation_errors(table) }

      if errors.any?
        puts red("Found #{errors.length} invalid records!")
        errors.each do |error|
          puts "- #{error[:model]} #{error[:slug] || error[:id]}: #{error[:errors].join(", ")}"
        end

        if StaticDb.parklife?
          puts red("Build failed!")
          exit 1
        else
          puts red("PROCEEDING TO DUMP DATA DESPITE VALIDATION ERRORS!!!")
          puts
          puts red("Set `config.load = false` to preserve the invalid data in your DB when restarting. Then you can fix the validation errors and retry dumping.")
        end
      else
        puts green("Done!")
      end
    end

    # Validates every row of the table once per model that owns the table, as an instance of
    # the row's own class: for single-table inheritance, Rails picks the subclass from the
    # type column. Scopes do not apply, so no row is left out.
    def validation_errors(table)
      table_models(table.name).flat_map do |model|
        table.rows.filter_map do |row|
          record = model.instantiate(row)
          next if record.valid?

          error = { model: record.class.name, id: record.id, errors: record.errors.full_messages }
          error[:slug] = record.slug if record.respond_to?(:slug)
          error
        rescue ActiveRecord::SubclassNotFound
          type = model.inheritance_column
          { model: model.name, id: row.values_at(*table.primary_key).join(", "), errors: [ "Unknown #{type} #{row[type].inspect}" ] }
        end
      end
    end

    # Models whose parent class does not use the same table: the base class of a
    # single-table inheritance hierarchy, or any other model of that table.
    def table_models(table_name)
      ActiveRecord::Base.descendants.select do |model|
        next false if model.abstract_class? || model.table_name != table_name

        parent = model.superclass
        parent == ActiveRecord::Base || parent.abstract_class? || parent.table_name != table_name
      end
    end

    def reset_data_directory!
      FileUtils.rm_rf(@static_db_path)
      FileUtils.mkdir_p(@static_db_path)
    end

    def dump_data!(tables)
      puts green("Dumping data ...")

      tables.each { |table| File.write(@static_db_path.join("#{table.name}.yml"), records(table).to_yaml) }

      puts green("Done!")
    end

    # A mapping from labels to records, or a list of records for a table without a primary
    # key, whose rows may not even be unique.
    def records(table)
      records = table.rows.map { |row| record(row, table.columns) }
      return records if table.primary_key.empty?

      labels = table.rows.map { |row| label(table, row) }
      raise "#{table.name}: labels are not unique" unless labels.uniq.size == labels.size

      labels.zip(records).to_h
    end

    def record(row, columns)
      columns.filter_map { |column| [ column.name, row[column.name] ] unless row[column.name].nil? }.to_h
    end

    # The table name and the primary key values, e.g. "posts_1" or "translations_de_hello".
    # With more than one key column, a value containing "_" or '"' is quoted, so that
    # ("a_b", "c") and ("a", "b_c") get different labels.
    def label(table, row)
      values = row.values_at(*table.primary_key).map(&:to_s)
      values = values.map { |value| value.match?(/[_"]/) ? value.inspect : value } if values.size > 1

      [ table.name, *values ].join("_")
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end
  end
end
