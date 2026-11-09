ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "translations", primary_key: [ "locale", "key" ], force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
  end
end
