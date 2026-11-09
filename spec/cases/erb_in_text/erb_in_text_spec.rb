RSpec.describe "Text that looks like ERB" do
  static_db_case do
    [
      "Use <%= 1 + 1 %> to print two.",
      "<% 3.times do %>x<% end %>",
      "<%# looks like a comment %>",
      "<%% already escaped %>",
      "Only a closing %> tag"
    ].each { |body| create(:erb_text, body:) }
  end
end
