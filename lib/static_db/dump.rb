module StaticDb
  class Dump
    attr_reader :models_to_be_saved

    def initialize(static_db_path: StaticDb.path)
      @static_db_path = Pathname.new(static_db_path)
      @models_to_be_saved = models
    end

    def perform
      exit 1 if $skip_static_db_dump

      validate_records!
      reset_data_directory!
      dump_data!
    end

    private

    def validate_records!
      puts green("Validating records ...")

      errors = []

      models_to_be_saved.each do |model|
        model.find_each do |record|
          next if record.valid?

          debug_data = { model: model.name, id: record.id, errors: record.errors.full_messages }
          debug_data[:slug] = record.slug if record.respond_to?(:slug)

          errors << debug_data
        end
      end

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

    def reset_data_directory!
      FileUtils.rm_rf(@static_db_path)
      FileUtils.mkdir_p(@static_db_path)
    end

    def dump_data!
      puts green("Dumping data ...")

      models_to_be_saved.each { |model| write_file!(path: file_path(model), data: data(model)) }

      puts green("Done!")
    end

    def write_file!(path:, data:)
      File.open(path, "w") { |file| file << data.to_yaml }
    end

    def file_path(model)
      File.join(@static_db_path, "#{model.table_name}.yml")
    end

    def data(model)
      model.unscoped.order(:id).to_h do |instance|
        [ "#{model}_#{instance.id}", instance_data(instance, model.columns) ]
      end
    end

    def instance_data(instance, columns)
      columns.filter_map do |column|
        value = instance.read_attribute_before_type_cast(column.name)
        next if value.nil?

        [ column.name, value ]
      end.to_h
    end

    def models
      Rails.application.eager_load!

      ActiveRecord::Base.descendants.select do |model|
         model.table_exists? && model.any? && model != ActiveRecord::SchemaMigration
      end
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end
  end
end
