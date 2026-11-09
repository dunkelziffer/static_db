ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.timestamps
  end

  create_table "posts", force: :cascade do |t|
    t.references "author", null: false, foreign_key: true
    t.string "title", null: false
    t.text "body"
    t.timestamps
  end
end
