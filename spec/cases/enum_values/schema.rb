ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "shirts", force: :cascade do |t|
    t.string "size"
  end
end
