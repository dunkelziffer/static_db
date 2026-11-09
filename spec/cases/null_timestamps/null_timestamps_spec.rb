# The dump leaves NULL out. Rails fixtures would fill in a missing created_at or updated_at
# with the current time.
RSpec.describe "NULL timestamps" do
  static_db_case do
    create(:event, name: "Imported without timestamps").update_columns(created_at: nil, updated_at: nil)
    create(:event, name: "Never updated").update_columns(updated_at: nil)
    create(:event, name: "Created and updated")
  end
end
