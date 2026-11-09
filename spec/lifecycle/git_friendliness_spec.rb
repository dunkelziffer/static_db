require "yaml"

# Data directories get committed, so a change in the app should be a small diff. Records are
# ordered by primary key, so a new one lands at its key's position: at the end for
# increasing integer ids, anywhere for UUIDs and composite keys.
RSpec.describe "Lifecycle - Git-friendliness" do
  def arrange_and_dump(&block)
    app.arrange(&block)
    expect(app.console(static_db: "dump")).to exit_successfully
    @before = app.files
  end

  def session(ruby)
    expect(app.console(static_db: "on", input: ruby)).to exit_successfully
    app.files
  end

  def changed_lines(before, after)
    before.lines.zip(after.lines).reject { |old, new| old == new }
  end

  def labels(yaml) = YAML.safe_load(yaml).keys

  # The file without one record's lines, wherever they are.
  def without_record(yaml, label) = yaml.sub(/^#{Regexp.escape(label)}:\n(?:  .*\n)*/, "")

  describe "with integer ids" do
    let(:app) { workspace("blog") }

    before do
      arrange_and_dump do
        author = create(:author, name: "Ursula K. Le Guin")
        create(:post, author:, title: "A Wizard of Earthsea")
        create(:post, author:, title: "The Tombs of Atuan")
      end
    end

    it "changes only the edited record's lines" do
      after = session('Post.find(1).update!(title: "The Farthest Shore")')

      expect(after["authors.yml"]).to eq(@before["authors.yml"])
      expect(changed_lines(@before["posts.yml"], after["posts.yml"])).to match([
        [ "  title: A Wizard of Earthsea\n", "  title: The Farthest Shore\n" ],
        [ "  updated_at: '2026-03-14 09:26:53.589793'\n", a_string_matching(/\A  updated_at: '\d{4}-.+'\n\z/) ]
      ])
    end

    it "adds a new record at the end, without changing the other records' lines" do
      after = session('Post.create!(author: Author.first, title: "Tehanu")')

      expect(labels(after["posts.yml"])).to eq(%w[posts_1 posts_2 posts_3])
      expect(without_record(after["posts.yml"], "posts_3")).to eq(@before["posts.yml"])
    end

    it "removes the file of a table whose rows are all deleted" do
      after = session("Post.delete_all")

      expect(after.keys).to eq(%w[authors.yml])
      expect(after["authors.yml"]).to eq(@before["authors.yml"])
    end
  end

  describe "with UUIDs" do
    let(:app) { workspace("uuid_primary_key") }
    let(:first) { "3a7d9e21-0c4b-4f6a-8e2d-5b1c9f0a6e47" }
    let(:middle) { "7e2b5c90-1d3f-4a8e-b6c7-9f0e2a4d1b58" }
    let(:last) { "c9f3a1d2-5b7e-4c8a-9d6f-2e1b0a7c4f35" }

    before do
      ids = [ first, last ]
      arrange_and_dump { ids.each { |id| create(:document, id:) } }
    end

    it "slots a new record in at its key's position, without changing the other records' lines" do
      after = session(%(Document.create!(id: "#{middle}", title: "In between")))

      expect(labels(after["documents.yml"])).to eq([ "documents_#{first}", "documents_#{middle}", "documents_#{last}" ])
      expect(without_record(after["documents.yml"], "documents_#{middle}")).to eq(@before["documents.yml"])
    end

    it "removes only a deleted record's lines" do
      after = session(%(Document.delete("#{first}")))

      expect(after["documents.yml"]).to eq(without_record(@before["documents.yml"], "documents_#{first}"))
    end
  end

  describe "with a composite primary key" do
    let(:app) { workspace("composite_primary_key") }

    before do
      arrange_and_dump do
        create(:translation, locale: "de", key: "bye", value: "Tschüss")
        create(:translation, locale: "en", key: "hello", value: "Hello")
      end
    end

    it "slots a new record in at its key's position, without changing the other records' lines" do
      after = session('Translation.create!(locale: "de", key: "hello", value: "Hallo")')

      expect(labels(after["translations.yml"])).to eq(%w[translations_de_bye translations_de_hello translations_en_hello])
      expect(without_record(after["translations.yml"], "translations_de_hello")).to eq(@before["translations.yml"])
    end

    it "changes only the edited record's lines" do
      after = session('Translation.find(["en", "hello"]).update!(value: "Hi")')

      expect(changed_lines(@before["translations.yml"], after["translations.yml"])).to eq([
        [ "  value: Hello\n", "  value: Hi\n" ]
      ])
    end
  end
end
