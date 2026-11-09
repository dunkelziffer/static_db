ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "string_values", force: :cascade do |t|
    t.string "value"
  end
end
