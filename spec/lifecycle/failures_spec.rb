RSpec.describe "Lifecycle - Failures" do
  let(:app) { workspace("blog") }

  describe "YAML that fails to load" do
    it "aborts the boot with exit status 1 and skips the dump, keeping the files" do
      app.arrange { create(:post) }
      expect(app.rails("static:dump")).to exit_successfully
      app.data_dir.join("posts.yml").write("Post_1:\n  title: [unclosed\n", mode: "a")
      broken = app.files

      result = app.console(static_db: "on")

      expect(result.status.exitstatus).to eq(1)
      expect(result.stdout).to include("Failed to load data", "Exiting and skipping StaticDb::Dump.")
      expect(app.files).to match_files(broken)
    end
  end

  describe "invalid records" do
    before do
      app.arrange do
        create(:author, name: "Valid")
        create(:author).update_column(:name, "")
      end
    end

    it "are reported, and dumped anyway, outside parklife" do
      result = app.console(static_db: "dump")

      expect(result).to exit_successfully
      expect(result.stdout).to include("Found 1 invalid records!", "- Author 2: Name can't be blank",
                                       "PROCEEDING TO DUMP DATA DESPITE VALIDATION ERRORS!!!")
      expect(app.files["authors.yml"]).to include("id: 2")
    end

    it "fail a parklife build without touching the files" do
      expect(app.console(static_db: "dump")).to exit_successfully
      dumped = app.files

      result = app.parklife("build", static_db: "on")

      expect(result.status.exitstatus).to eq(1)
      expect(result.stdout).to include("Found 1 invalid records!", "Build failed!")
      expect(app.files).to match_files(dumped)
    end
  end
end
