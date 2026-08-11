RSpec.describe StaticDb::Load do
  def dump_to(dir) = quietly { StaticDb::Dump.new(static_db_path: dir).perform }

  describe "#perform" do
    # Characterisation of a known defect, recorded so the fix has a reproduction to
    # invert. In RAILS_ENV=test the reset unlinks the database file and never puts one
    # back: db:check_protected_environments opens a connection, db:drop unlinks the
    # path, and the db:create that follows reuses that pool rather than opening the
    # path again — so db:schema:load writes a schema into an inode with no name.
    # Nothing raises and the exit status is 0.
    it "unlinks the database file without recreating it" do
      expect(File.exist?(DummyApp.database_path)).to be(true)

      seed_corpus!
      dump_to(dir = static_db_dir)

      quietly { described_class.new(static_db_path: dir).perform }

      expect(File.exist?(DummyApp.database_path)).to be(false)
      expect(Author.count).to eq(2) # ...while this process still reads the orphan
    end

    it "replaces rows that are absent from the YAML" do
      seed_corpus!
      dump_to(dir = static_db_dir)
      Author.create!(name: "added after the dump")

      quietly { described_class.new(static_db_path: dir).perform }

      expect(Author.pluck(:name)).not_to include("added after the dump")
    end
  end
end
