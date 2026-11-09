# Rails fixtures would replace a value that equals an enum key with that key's value. Here,
# rows from before the enum switched to short codes still hold the full names.
RSpec.describe "Enum columns holding a key instead of a value" do
  static_db_case do
    create(:shirt, size: :small)
    create(:shirt, size: :large)
    execute("INSERT INTO shirts (size) VALUES ('medium')")
  end
end
