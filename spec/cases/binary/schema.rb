ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "binary_values", force: :cascade do |t|
    t.binary "data"
  end
end
