# Proves the harness itself works before anything relies on it. If these fail, no
# other spec's result means anything.
RSpec.describe "the test harness" do
  it "boots the dummy application with the engine loaded" do
    expect(Rails.application).to be_a(Dummy::Application)
    expect(Rails.application.railties).to include(an_instance_of(StaticDb::Engine))
  end

  it "leaves the boot hooks inactive outside a server, console or parklife build" do
    expect(StaticDb.load?).to be(false)
    expect(StaticDb.dump?).to be(false)
    expect(StaticDb.parklife?).to be(false)
  end

  it "has the schema loaded" do
    expect(db_snapshot.keys).to contain_exactly("authors", "posts")
  end

  it "can seed the corpus" do
    seed_corpus!

    expect(Author.count).to eq(2)
    expect(Post.count).to eq(3)
  end

  it "truncates between examples" do
    expect(db_snapshot.values.flatten).to be_empty
  end

  describe "primary key determinism" do
    it "rewinds ids between examples" do
      expect(Author.create!(name: "first").id).to eq(1)
    end

    it "rewinds them again on the next truncation" do
      Author.create!(name: "a")
      Author.create!(name: "b")
      DummyApp.truncate!

      expect(Author.create!(name: "c").id).to eq(1)
    end

    # Guards the `main.` qualifier in DummyApp.truncate!: the unqualified name hits an
    # always-empty temp.sqlite_sequence, and the reset silently stops working.
    it "tracks the sequence in the main database, not temp" do
      Author.create!(name: "a")
      conn = ActiveRecord::Base.lease_connection

      expect(conn.select_all("SELECT name, seq FROM main.sqlite_sequence").to_a)
        .to include("name" => "authors", "seq" => 1)
      expect(conn.select_all("SELECT name, seq FROM sqlite_sequence").to_a).to be_empty
    end
  end

  describe "config isolation" do
    it "restores whatever an example changes" do
      StaticDb.config.load = true
      StaticDb.config.static_db_path = "/somewhere/else"

      expect(StaticDb.load?).to be(true)
    end

    it "sees the defaults again in the next example" do
      expect(StaticDb.load?).to be(false)
      expect(StaticDb.path).to eq(Rails.root.join("content", "data"))
    end
  end

  describe "fixture cache" do
    let(:dir) { static_db_dir }

    before do
      File.write(dir.join("authors.yml"), { "Author_1" => { "id" => 1, "name" => "cached?" } }.to_yaml)
    end

    # Both examples load the same fixture set name. Without reset_cache the second
    # one would silently insert nothing — the failure mode that makes a green suite
    # meaningless.
    2.times do |i|
      it "actually inserts on load ##{i + 1}" do
        ActiveRecord::FixtureSet.create_fixtures(dir, [ "authors" ])

        expect(Author.count).to eq(1)
      end
    end
  end

  describe "snapshot helpers" do
    it "reads the database at the adapter level, ordered by primary key" do
      seed_corpus!

      expect(db_snapshot["authors"].map { |row| row["name"] }).to eq([ "Otfried Preußler", "Ursula K. Le Guin" ])
      expect(db_snapshot["authors"].first.keys).to include("id", "name", "created_at", "updated_at")
    end

    it "reads a directory as raw bytes" do
      dir = static_db_dir
      File.write(dir.join("authors.yml"), "---\n")

      expect(dir_snapshot(dir)).to eq({ "authors.yml" => "---\n" })
    end

    it "treats a missing directory as empty" do
      expect(dir_snapshot("/nonexistent")).to eq({})
    end
  end
end
