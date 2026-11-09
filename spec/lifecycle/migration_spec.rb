require "yaml"

# Schema changes need a manual round trip, with no server running:
#
#   bin/rails static:load
#   (write the migration)
#   bin/rails db:migrate static:dump
RSpec.describe "Lifecycle - Applying a migration" do
  let(:app) { workspace("migration") }

  before do
    app.arrange do
      create(:article, title: "Old")
      create(:article, title: "Older")
    end
    expect(app.console(static_db: "dump")).to exit_successfully # the last session before the migration

    expect(app.rails("static:load")).to exit_successfully
    expect(app.rails("db:migrate", "static:dump")).to exit_successfully
  end

  it "gives existing rows the new columns' defaults, in the YAML and in the next session" do
    expect(YAML.safe_load(app.files["articles.yml"])).to eq(
      "Article_1" => { "id" => 1, "title" => "Old", "featured" => 0, "rating" => 3 },
      "Article_2" => { "id" => 2, "title" => "Older", "featured" => 0, "rating" => 3 }
    )

    expect(app.console(static_db: "on")).to exit_successfully
    expect(app.snapshot).to eq("articles" => [
      { "id" => 1, "title" => "Old", "featured" => 0, "rating" => 3 },
      { "id" => 2, "title" => "Older", "featured" => 0, "rating" => 3 }
    ])
  end
end
