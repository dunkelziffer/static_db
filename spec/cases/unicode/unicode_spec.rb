RSpec.describe "Unicode text" do
  static_db_case do
    [
      "Grüße aus München",
      "日本語のテキスト",
      "עברית ושלום",
      "مرحبا بالعالم",
      "emoji 😀 and skin tone 👍🏽",
      "family 👨‍👩‍👧 joined with zero-width joiners",
      "é decomposed (NFD)",
      "é composed (NFC)",
      "non breaking space",
      "zero​width space",
      "byte order mark ﻿ inside"
    ].each { |value| create(:unicode_value, value:) }
  end
end
