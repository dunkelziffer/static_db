# `StaticDb.config` is process-global mutable state and the suite runs in random order,
# so anything an example sets has to be handed back afterwards.
module StaticDbConfig
  OPTIONS = %i[static_db_path load dump].freeze

  def self.snapshot = OPTIONS.to_h { |option| [ option, StaticDb.config.public_send(option) ] }

  def self.restore(values)
    values.each { |option, value| StaticDb.config.public_send("#{option}=", value) }
  end
end

RSpec.configure do |config|
  config.around do |example|
    saved = StaticDbConfig.snapshot

    begin
      example.run
    ensure
      StaticDbConfig.restore(saved)
    end
  end
end
