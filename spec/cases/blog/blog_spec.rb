# A small app with an association, a foreign key, timestamps and a gap in the ids.
RSpec.describe "Associated records" do
  static_db_case do
    preussler = create(:author, name: "Otfried Preußler")
    le_guin = create(:author, name: "Ursula K. Le Guin")

    create(:post, author: preussler, title: "Krabat", body: "Die Mühle im Koselbruch mahlt nicht nur Korn.")
    create(:post, author: le_guin, title: "A Wizard of Earthsea", body: "Only in silence the word.")
    create(:post, author: le_guin, title: "Deleted draft").destroy
    create(:post, author: le_guin, title: "The Tombs of Atuan")
  end
end
