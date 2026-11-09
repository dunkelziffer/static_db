# Active Storage keeps its records in three tables of its own, with models from the engine,
# and the files themselves outside the database.
RSpec.describe "Active Storage attachments" do
  static_db_case do
    create(:profile, :with_avatar, :with_documents, name: "Ada")
    create(:profile, :with_avatar, name: "Grace")
    create(:profile, name: "Edsger")
  end

  it "keeps the attached files readable after a load" do
    app = workspace("active_storage")
    app.arrange { create(:profile, :with_avatar, name: "Ada") }
    expect(app.console(static_db: "dump")).to exit_successfully

    result = app.console(static_db: "on", input: "puts Profile.first.avatar.download")

    expect(result).to exit_successfully
    expect(result.stdout).to include("Ada's avatar")
  end
end
