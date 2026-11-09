ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "notes", force: :cascade do |t|
    t.string "title"
    t.boolean "archived", default: false, null: false
  end
end
