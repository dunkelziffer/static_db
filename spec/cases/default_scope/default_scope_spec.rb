RSpec.describe "Records hidden by a default scope" do
  static_db_case do
    create(:note, title: "Visible")
    create(:note, title: "Archived", archived: true)
  end

  it "are validated before dumping" do
    app = workspace("default_scope")
    app.arrange { create(:note, archived: true).update_column(:title, "") }

    result = app.console(static_db: "dump")

    expect(result.stdout).to include("Found 1 invalid records!", "- Note 1: Title can't be blank")
  end

  it "are dumped when the default scope hides all of them" do
    app = workspace("default_scope")
    app.arrange { create(:note, title: "Archived", archived: true) }

    expect(app.console(static_db: "dump")).to exit_successfully

    expect(app.files.keys).to eq(%w[notes.yml])
  end
end
