module StaticDb
  class Dump

    attr_reader :fixture_path, :models_to_be_saved

    def initialize(fixture_path:)
      @fixture_path = Pathname.new(fixture_path)
      @models_to_be_saved = models
    end

    def perform
      exit 1 if $skip_active_fixtures_dump

      reenable_rake_tasks!
      validate_records!

      puts green("Dumping fixtures ...")

      dump_fixtures!
      Rake::Task["db:drop"].invoke

      puts green("Done!")
    end

    private

    def reenable_rake_tasks!
      ["db:drop"].each do |task_name|
        Rake::Task[task_name].reenable
      end
    end

    def validate_records!
      puts green("Validating records ...")

      errors = []

      models_to_be_saved.each do |model|
        model.find_each do |record|
          unless record.valid?
            errors << { model: model.name, slug: record.slug, errors: record.errors.full_messages }
          end
        end
      end

      if errors.any?
        puts red("Found #{errors.length} invalid records!")
        errors.each do |error|
          puts "- #{error[:model]} #{error[:slug]}: #{error[:errors].join(", ")}"
        end
        if ARGV.first == "build"
          puts red("Build failed!")
          exit 1
        else
          puts red("Please fix the invalid records before creating a PR!")
        end
      else
        puts green("Done!")
      end
    end

    def dump_fixtures!
      reset_data_directory!
      models_to_be_saved.each { |model| format_and_write_yaml_file!(model) }
    end

    def reset_data_directory!
      FileUtils.rm_rf(fixture_path)
      FileUtils.mkdir_p(fixture_path)
    end

    def format_and_write_yaml_file!(model)
      instances = fetch_model_instances(model)
      output = format_instances(model: model, instances: instances)
      write_yaml_file!(model: model, data: output)
    end

    def fetch_model_instances(model)
      model.unscoped.all.order('id ASC')
    end

    # TODO: check against old implementation!
    def format_instances(model:, instances:)
      output = {}

      instances.each do |instance|
        attrs = {}

        model.columns.each do |column|
          value = instance.read_attribute_before_type_cast(column.name)
          attrs[column.name] = value unless value.nil?
        end

        output["#{model}_#{model.id}"] = attrs
      end

      output
    end

    def write_yaml_file!(model:, data:)
      File.open(yaml_file_path(model), 'w') { |file| file << data.to_yaml }
    end

    def models
      Rails.application.eager_load!
      models = ActiveRecord::Base.descendants
      models.select! { |model| model.table_exists? && model.any? }
      models.delete(ActiveRecord::SchemaMigration)
      models
    end

    def yaml_file_path(model)
      File.join(fixture_path, generate_file_name(model) + '.yml')
    end

    def generate_file_name(model)
      model.table_name
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def red(text)
      "\e[31m#{text}\e[0m"
    end

  end
end
