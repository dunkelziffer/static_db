RSpec.describe "A string primary key not called id" do
  static_db_case do
    create(:country, code: "DE", name: "Germany")
    create(:country, code: "AT", name: "Austria")
  end
end
