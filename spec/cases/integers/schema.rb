ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "integer_values", force: :cascade do |t|
    t.integer "regular"
    t.bigint "big"
  end
end
