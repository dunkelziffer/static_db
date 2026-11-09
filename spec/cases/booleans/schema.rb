ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "boolean_values", force: :cascade do |t|
    t.boolean "flag"
  end
end
