ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "vehicles", force: :cascade do |t|
    t.string "name"
    t.string "type"
  end
end
