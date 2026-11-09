# Strings that YAML, unquoted, would read as something else.
RSpec.describe "Strings that look like other YAML values" do
  static_db_case do
    [
      "plain",
      "yes", "no", "on", "off", "y", "n", "true", "false", "True", "NO",
      "null", "Null", "~", "nil",
      "0123", "123", "-5", "1.5", ".5", "1e5", "1_000", "0x1F", "0o17", "0b101", "12:30", "1:20:30",
      ".inf", "-.Inf", ".nan",
      "2020-01-01", "2020-01-01 12:00:00",
      ":symbol", "- dash", "# hash", "key: value", "trailing colon:", "comma, separated",
      "!tag", "&anchor", "*alias", "? question", "| pipe", "> folded", "---", "...",
      "'single'", '"double"', "%percent", "@at", "`backtick`", "{ braces }", "[ brackets ]"
    ].each { |value| create(:string_value, value:) }
  end
end
