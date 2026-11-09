# Whitespace and line breaks, where YAML block scalars have opinions about chomping and folding.
RSpec.describe "Whitespace and multi-line text" do
  static_db_case do
    [
      "",
      " ",
      "  leading spaces",
      "trailing spaces  ",
      "\n",
      "one line\n",
      "two\nlines",
      "two\nlines\n",
      "ends with blank lines\n\n\n",
      "\n\nstarts with blank lines",
      "  indented\n    block",
      "\ttab\tseparated",
      "windows\r\nline endings\r\n",
      "a long line that YAML might fold " * 10,
      ("a paragraph of text " * 10 + "\n") * 3
    ].each { |body| create(:text_value, body:) }
  end
end
