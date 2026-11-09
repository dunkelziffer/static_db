ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "articles", force: :cascade do |t|
    t.string "title"
  end
end
