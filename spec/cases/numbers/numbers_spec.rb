RSpec.describe "Floats and decimals" do
  static_db_case do
    floats = [ 0.1, 0.1 + 0.2, 1.0, -2.5, 1e-300, Float::MAX, 123456789.123456789, 2.0**53 ]
    decimals = %w[0.1 12.3400 0 -99999999.9999 1 3.1416 0.0001 -0.5]

    floats.zip(decimals).each do |float, decimal|
      create(:number_value, float_value: float, decimal_value: decimal)
    end
  end
end
