ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.timestamps null: true
  end
end
