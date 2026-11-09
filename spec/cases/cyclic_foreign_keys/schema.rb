ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "ceo_id"
    t.index [ "ceo_id" ], name: "index_companies_on_ceo_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "team_id", null: false
    t.index [ "team_id" ], name: "index_people_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "company_id", null: false
    t.index [ "company_id" ], name: "index_teams_on_company_id"
  end

  add_foreign_key "companies", "people", column: "ceo_id"
  add_foreign_key "people", "teams"
  add_foreign_key "teams", "companies"
end
