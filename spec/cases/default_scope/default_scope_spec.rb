RSpec.describe "Records hidden by a default scope" do
  static_db_case do
    create(:note, title: "Visible")
    create(:note, title: "Archived", archived: true)
  end
end
