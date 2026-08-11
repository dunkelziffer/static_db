ActiveRecord::Schema[ActiveRecord::Migration.current_version].define(version: 2026_08_11_000001) do
  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer "author_id", null: false
    t.string "title", null: false
    t.text "body"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "author_id" ], name: "index_posts_on_author_id"
  end

  add_foreign_key "posts", "authors"
end
