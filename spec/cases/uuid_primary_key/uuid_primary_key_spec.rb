# UUIDs sort as strings, so the records are ordered by key, not by when they were created.
# The ids are fixed here; the app generates random ones.
RSpec.describe "UUID primary keys" do
  static_db_case do
    create(:document, id: "c9f3a1d2-5b7e-4c8a-9d6f-2e1b0a7c4f35", title: "Created first")
    create(:document, id: "3a7d9e21-0c4b-4f6a-8e2d-5b1c9f0a6e47", title: "Created second")
  end
end
