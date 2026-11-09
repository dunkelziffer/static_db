# Columns are dumped alphabetically, after the primary key columns (Array(model.primary_key)),
# so the order in the YAML does not depend on the order in which migrations added them.
RSpec.describe "Column order" do
  static_db_case do
    create(:shuffled_column, zebra: "z", apple: "a", mango: "m")
  end
end
