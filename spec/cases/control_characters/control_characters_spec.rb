# Characters YAML cannot write as plain text and has to escape, or treats as line breaks.
RSpec.describe "Control characters and Unicode line breaks" do
  static_db_case do
    [
      "bell\a",
      "escape \e[31mred\e[0m",
      "start of heading\u0001",
      "backspace\b",
      "vertical\vtab",
      "form\ffeed",
      "delete\u007f",
      "next line\u0085character",
      "line separator",
      "paragraph separator"
    ].each { |value| create(:control_value, value:) }
  end
end
