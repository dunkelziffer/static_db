RSpec.describe "Booleans" do
  static_db_case do
    create(:boolean_value, flag: true)
    create(:boolean_value, flag: false)
  end
end
