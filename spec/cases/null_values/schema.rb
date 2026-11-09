ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "nullable_values", force: :cascade do |t|
    t.string "string_value"
    t.text "text_value"
    t.integer "integer_value"
    t.float "float_value"
    t.boolean "boolean_value"
    t.datetime "datetime_value"
    t.date "date_value"
    t.binary "binary_value"
  end
end
