# Turns a database state into the three examples every case shares:
#
#   arrange              DB                    (FactoryBot, in a booted app)
#   session 1: dump      DB → YAML             must match the committed golden files
#   session 2: load+dump YAML → DB′ → YAML′    DB′ must equal DB, YAML′ must equal YAML
#
# The database is the source of truth: every state it can hold must survive a round trip,
# and YAML that static_db dumped must survive one unchanged.
#
# Both sessions run once per case, before its examples, which only check the results.
# The case directory is the one the spec file lives in. `pending:` gives the reason and
# `failing:` the properties whose examples are pending, so they flip once they pass.
module StaticDbCase
  PROPERTIES = {
    golden: "dumps to the committed YAML",
    round_trip: "loads the dump back into an identical database",
    fixed_point: "dumps the reloaded database to identical YAML"
  }.freeze

  def static_db_case(pending: nil, failing: [], &arrange)
    raise ArgumentError, "unknown properties: #{failing - PROPERTIES.keys}" unless (failing - PROPERTIES.keys).empty?
    raise ArgumentError, "pending: and failing: go together" unless pending.nil? == failing.empty?

    case_dir = Pathname(metadata[:absolute_file_path]).dirname
    options = ->(property) { failing.include?(property) ? { pending: } : {} }
    title = ->(property) { "#{PROPERTIES[property]} (#{property})" }

    before(:context) do
      @workspace = Workspace.new(case_dir)
      @arranged = @workspace.arrange(&arrange)
      @dump_session = @workspace.console(static_db: "dump")
      @first_dump = @workspace.files
      @reload_session = @workspace.console(static_db: "on")
      @reloaded = @workspace.snapshot
      @second_dump = @workspace.files
    end
    after(:context) { @workspace&.cleanup }

    it title[:golden], **options[:golden] do
      expect(@dump_session).to exit_successfully
      StaticDbCase.write_golden(@workspace.golden_dir, @first_dump) if ENV["UPDATE_GOLDEN"] && !failing.include?(:golden)
      expect(@first_dump).to match_files(Snapshot.files(@workspace.golden_dir))
    end

    it title[:round_trip], **options[:round_trip] do
      expect(@reload_session).to exit_successfully
      expect(@reloaded).to eq(@arranged)
    end

    it title[:fixed_point], **options[:fixed_point] do
      expect(@reload_session).to exit_successfully
      expect(@second_dump).to match_files(@first_dump)
    end
  end

  # Golden files are reviewed dump output. Only UPDATE_GOLDEN=1 writes them, and never
  # for a case whose golden example is pending: there they are hand-written to the
  # target format.
  def self.write_golden(dir, files)
    FileUtils.rm_rf(dir)
    dir.mkpath
    files.each { |name, bytes| dir.join(name).binwrite(bytes) }
  end
end

RSpec.configure { |config| config.extend StaticDbCase }
