# Labels hold every key value, in the order of the key: (locale, key). With more than one
# value, those containing "_" or '"' are quoted.
RSpec.describe "A composite primary key" do
  static_db_case do
    create(:translation, locale: "de", key: "hello", value: "Hallo")
    create(:translation, locale: "en", key: "hello", value: "Hello")
    create(:translation, locale: "de", key: "bye", value: "Tschüss")
    create(:translation, locale: "de", key: "user_name", value: "Benutzername")
    # Unquoted, both would be translations_pt_BR_hello.
    create(:translation, locale: "pt_BR", key: "hello", value: "Olá")
    create(:translation, locale: "pt", key: "BR_hello", value: "Olá, Brasil")
    create(:translation, locale: "en", key: %(say "hi"), value: "Hi!")
  end
end
