ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "books", force: :cascade do |t|
    t.string "title"
  end

  create_table "readers", force: :cascade do |t|
    t.string "name"
  end

  create_table "books_readers", id: false, force: :cascade do |t|
    t.references "book", null: false
    t.references "reader", null: false
  end
end
