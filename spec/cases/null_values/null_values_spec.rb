# NULL in columns without a default. Dump leaves NULL out, and load leaves the column out
# of the INSERT, which yields NULL here because there is no default to fill in.
RSpec.describe "NULL in columns without a default" do
  static_db_case do
    create(:nullable_value)
    # Empty and falsy values, which must not collapse into NULL.
    create(:nullable_value, string_value: "", text_value: "", integer_value: 0, float_value: 0.0,
                            boolean_value: false, binary_value: "".b)
  end
end
