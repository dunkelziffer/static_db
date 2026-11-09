# NULL values are left out of the dump, and a missing key loads as NULL, not as the
# column default.
RSpec.describe "NULL in nullable columns with a default" do
  static_db_case do
    create(:defaulted_value, published: nil, flavor: nil, count: nil)
    create(:defaulted_value, published: false, flavor: "chocolate", count: 5)
    create(:defaulted_value, published: true, flavor: "vanilla", count: 0)
  end
end
