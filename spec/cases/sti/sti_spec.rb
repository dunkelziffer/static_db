# All rows of a table go into one file, whichever class they belong to.
RSpec.describe "Single-table inheritance" do
  static_db_case do
    create(:vehicle, name: "Generic vehicle")
    create(:car, name: "Car")
    create(:bike, name: "Bike")
    create(:car, name: "Another car")
  end

  describe "validation" do
    let(:app) { workspace("sti") }

    it "checks each row once, with the validations of its own class" do
      app.arrange do
        create(:vehicle, name: "") # Only cars need a name.
        create(:car, name: "Car").update_column(:name, "")
      end

      result = app.console(static_db: "dump")

      expect(result.stdout).to include("Found 1 invalid records!", "- Car 2: Name can't be blank")
    end

    it "reports rows whose class does not exist, and dumps them anyway" do
      app.arrange { execute("INSERT INTO vehicles (name, type) VALUES ('Plane', 'Plane')") }

      result = app.console(static_db: "dump")

      expect(result).to exit_successfully
      expect(result.stdout).to include("Found 1 invalid records!", %(- Vehicle 1: Unknown type "Plane"))
      expect(app.files["vehicles.yml"]).to include("type: Plane")
    end
  end
end
