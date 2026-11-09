ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "snippets", force: :cascade do |t|
    t.text "body"
  end
end
