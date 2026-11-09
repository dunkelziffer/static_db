# A join table has no primary key, so nothing makes its rows unique: they are dumped as a
# list instead of labeled records, ordered by all columns.
RSpec.describe "A has_and_belongs_to_many join table" do
  static_db_case do
    krabat = create(:book, title: "Krabat")
    earthsea = create(:book, title: "A Wizard of Earthsea")

    create(:reader, name: "Anna", books: [ krabat, earthsea ])
    ben = create(:reader, name: "Ben", books: [ earthsea ])
    ben.books << earthsea # Without a unique index, the same pair can appear twice.
  end
end
