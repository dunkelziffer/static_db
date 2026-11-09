# The database computes generated columns and refuses values for them. The dump leaves
# them out: they are not data of their own, and editing them in the YAML could not change
# anything.
RSpec.describe "Generated columns" do
  static_db_case do
    create(:person, first_name: "Ada", last_name: "Lovelace")
    create(:person, first_name: "Grace", last_name: "Hopper")
  end
end
