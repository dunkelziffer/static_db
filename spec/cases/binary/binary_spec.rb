RSpec.describe "Binary data" do
  static_db_case do
    [
      "\x00\x01\x02\xFF".b,
      (0..255).to_a.pack("C*"),
      "\x89PNG\r\n\x1A\n".b,
      "UTF-8 bytes: Grüße".b,
      "plain ascii".b,
      "".b
    ].each { |data| create(:binary_value, data:) }
  end
end
