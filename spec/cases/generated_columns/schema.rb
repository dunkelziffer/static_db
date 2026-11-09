ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "people", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.virtual "full_name", type: :string, as: "first_name || ' ' || last_name", stored: true
    t.virtual "initials", type: :string, as: "substr(first_name, 1, 1) || substr(last_name, 1, 1)"
  end
end
