ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "erb_texts", force: :cascade do |t|
    t.text "body"
  end
end
