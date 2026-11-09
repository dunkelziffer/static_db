RSpec.describe "JSON columns" do
  static_db_case do
    [
      { "a" => 1 },
      { "b" => 1, "a" => 2 }, # key order is part of the stored text
      {},
      [],
      { "nested" => { "list" => [ 1, "two", nil, true ] } },
      "just a string",
      42
    ].each { |payload| create(:json_value, payload:) }
  end
end
