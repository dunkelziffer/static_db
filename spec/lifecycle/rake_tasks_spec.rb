RSpec.describe "Lifecycle - Rake tasks" do
  let(:app) { workspace("blog") }

  describe "in development" do
    before { @arranged = app.arrange { create(:post) } }

    it "dump to and load from the configured directory" do
      expect(app.rails("static:dump")).to exit_successfully
      expect(app.files.keys).to eq(%w[authors.yml posts.yml])

      app.change { create(:post, title: "Not dumped") }
      expect(app.rails("static:load")).to exit_successfully

      expect(app.snapshot).to eq(@arranged)
    end

    it "take a directory relative to Rails.root" do
      elsewhere = app.root.join("elsewhere")
      relative = elsewhere.relative_path_from(DummyApp::ROOT)

      expect(app.rails("static:dump[#{relative}]")).to exit_successfully
      expect(Snapshot.files(elsewhere).keys).to eq(%w[authors.yml posts.yml])
      expect(app.files).to be_empty

      app.change { create(:post, title: "Not dumped") }
      expect(app.rails("static:load[#{relative}]")).to exit_successfully

      expect(app.snapshot).to eq(@arranged)
    end
  end
end
