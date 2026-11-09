ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "defaulted_values", force: :cascade do |t|
    t.boolean "published", default: true
    t.string "flavor", default: "vanilla"
    t.integer "count", default: 0
  end
end
