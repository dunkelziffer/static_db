ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "countries", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "name"
  end
end
