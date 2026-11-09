# companies.ceo_id → people.team_id → teams.company_id → companies: whatever order the
# tables are loaded in, some rows refer to rows that are not there yet. Only the CEO is
# nullable, so the records can be created one after another.
RSpec.describe "Cyclic foreign keys" do
  static_db_case do
    acme = create(:company, name: "Acme")
    platform = create(:team, company: acme, name: "Platform")
    ada = create(:person, team: platform, name: "Ada")
    create(:person, team: platform, name: "Grace")
    create(:team, company: acme, name: "Design")
    acme.update!(ceo: ada)

    create(:company, name: "Startup without a CEO")
  end

  # Otherwise the round trip would pass in any load order.
  it "are enforced by the database" do
    app = workspace("cyclic_foreign_keys")
    app.arrange { create(:company) }

    expect { app.change { execute("INSERT INTO people (name, team_id) VALUES ('Nobody', 999)") } }
      .to raise_error(DummyApp::ChildError, /FOREIGN KEY constraint failed/)
  end
end
