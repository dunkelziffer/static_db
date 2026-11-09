# When the hooks fire, per the README's "Hook activation" section. Each example starts
# from YAML that is missing one row of the database: a load drops that row, a dump
# rewrites the files.
RSpec.describe "Lifecycle - Boot hooks" do
  let(:app) { workspace("blog") }
  let(:root_data_dir) { DummyApp::ROOT.join("content") }
  let(:env) { {} }

  before do
    app.arrange(env:) { create(:post, title: "Dumped") }
    expect(app.rails("static:dump", env:)).to exit_successfully
    app.change(env:) { create(:post, title: "Not dumped yet") }
  end

  def titles = app.snapshot(env:)["posts"].map { |post| post["title"] }
  def mtimes = app.data_dir.children.to_h { |file| [ file.basename.to_s, file.mtime ] }

  shared_examples "a command that runs the hooks" do
    it "loads at boot and dumps at exit" do
      dumped = app.files
      before = mtimes

      expect(run).to exit_successfully

      expect(titles).to eq([ "Dumped" ])
      expect(app.files).to match_files(dumped)
      expect(mtimes.values).to all(be > before.values.max)
    end
  end

  shared_examples "a command that leaves the hooks alone" do
    it "neither loads nor dumps" do
      dumped = app.files
      before = mtimes

      expect(run).to exit_successfully

      expect(titles).to eq([ "Dumped", "Not dumped yet" ])
      expect(app.files).to match_files(dumped)
      expect(mtimes).to eq(before)
    end
  end

  describe "bin/rails console" do
    let(:run) { app.console(static_db: "on") }

    it_behaves_like "a command that runs the hooks"
  end

  describe "parklife build" do
    let(:run) { app.parklife("build", static_db: "on") }

    it_behaves_like "a command that runs the hooks"
  end

  describe "parklife serve" do
    let(:run) { app.parklife("serve", static_db: "on") }

    it_behaves_like "a command that leaves the hooks alone"
  end

  describe "bin/rails runner" do
    let(:run) { app.rails("runner", "nil", env: { "STATIC_DB" => "on" }) }

    it_behaves_like "a command that leaves the hooks alone"
  end

  describe "bin/rails db:migrate" do
    let(:run) { app.rails("db:migrate", env: { "STATIC_DB" => "on" }) }

    it_behaves_like "a command that leaves the hooks alone"
  end

  # What spec/rails_helper.rb or test/test_helper.rb does.
  describe "a test suite booting the app" do
    let(:env) { { "RAILS_ENV" => "test" } }
    let(:run) { DummyApp.run(RbConfig.ruby, "-e", 'require "./config/environment"', env: app.env("STATIC_DB" => "on", **env)) }

    it_behaves_like "a command that leaves the hooks alone"
  end

  describe "bin/rails console without any static_db configuration" do
    let(:run) { app.console(static_db: "on", env: { "DUMMY_UNCONFIGURED" => "1" }) }

    it_behaves_like "a command that leaves the hooks alone"

    it "does not create the default data directory" do
      expect(run).to exit_successfully
      expect(root_data_dir).not_to exist
    end
  end

  # Load replaces the database file from a subprocess. A connection opened during boot would
  # keep writing to the deleted file, but Active Record's own after_initialize hook, which runs
  # before static_db's, disconnects idle connections.
  describe "an app that queries the database while booting" do
    it "loads into the database file" do
      expect(app.console(static_db: "load", env: { "DUMMY_QUERY_DATABASE_AT_BOOT" => "1" })).to exit_successfully

      expect(titles).to eq([ "Dumped" ])
    end
  end
end
