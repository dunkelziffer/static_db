ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "json_values", force: :cascade do |t|
    t.json "payload"
  end
end
