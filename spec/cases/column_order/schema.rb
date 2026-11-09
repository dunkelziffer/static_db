ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "shuffled_columns", force: :cascade do |t|
    t.string "zebra"
    t.string "apple"
    t.string "mango"
  end
end
