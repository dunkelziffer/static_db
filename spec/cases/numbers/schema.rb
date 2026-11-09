ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "number_values", force: :cascade do |t|
    t.float "float_value"
    t.decimal "decimal_value", precision: 12, scale: 4
  end
end
