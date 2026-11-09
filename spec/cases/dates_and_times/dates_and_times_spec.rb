RSpec.describe "Dates and times" do
  static_db_case do
    create(:temporal_value, happened_at: Time.utc(1969, 7, 20, 20, 17, 40), happened_on: Date.new(1969, 7, 20),
                            time_of_day: "20:17:40")
    create(:temporal_value, happened_at: Time.utc(2038, 1, 19, 3, 14, 8, 123_456), happened_on: Date.new(2024, 2, 29),
                            time_of_day: "23:59:59.999999")
    create(:temporal_value, happened_at: Time.new(2026, 3, 14, 10, 0, 0, "+01:00"), happened_on: Date.new(1900, 1, 1),
                            time_of_day: "00:00:00")
  end
end
