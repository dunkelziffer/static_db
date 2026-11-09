ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "temporal_values", force: :cascade do |t|
    t.datetime "happened_at"
    t.date "happened_on"
    t.time "time_of_day"
    t.timestamps
  end
end
