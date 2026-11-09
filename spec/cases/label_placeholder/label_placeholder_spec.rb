# Rails fixtures would replace "$LABEL" in every string with the fixture's label.
RSpec.describe "Text containing $LABEL" do
  static_db_case do
    [
      "$LABEL",
      "Fixtures replace $LABEL with the fixture's name.",
      "export LABEL=x; echo $LABEL"
    ].each { |body| create(:snippet, body:) }
  end
end
