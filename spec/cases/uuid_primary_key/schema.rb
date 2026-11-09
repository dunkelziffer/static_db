ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "documents", id: :string, force: :cascade do |t|
    t.string "title", null: false
  end
end
