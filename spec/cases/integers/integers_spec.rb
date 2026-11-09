RSpec.describe "Integers" do
  static_db_case do
    create(:integer_value, regular: 0, big: 0)
    create(:integer_value, regular: -1, big: 2**53 + 1) # beyond what a Float holds exactly
    create(:integer_value, regular: 2**31 - 1, big: 2**63 - 1)
    create(:integer_value, regular: -2**31, big: -2**63)
  end
end
