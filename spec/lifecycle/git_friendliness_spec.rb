# Data directories get committed, so a change in the app should be a small diff.
RSpec.describe "Lifecycle - Git-friendliness" do
  let(:app) { workspace("blog") }

  before do
    app.arrange do
      author = create(:author, name: "Ursula K. Le Guin")
      create(:post, author:, title: "A Wizard of Earthsea")
      create(:post, author:, title: "The Tombs of Atuan")
    end
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

  it "changes only the edited record's lines" do
    after = session('Post.find(1).update!(title: "The Farthest Shore")')

    expect(after["authors.yml"]).to eq(@before["authors.yml"])
    expect(changed_lines(@before["posts.yml"], after["posts.yml"])).to match([
      [ "  title: A Wizard of Earthsea\n", "  title: The Farthest Shore\n" ],
      [ "  updated_at: '2026-03-14 09:26:53.589793'\n", a_string_matching(/\A  updated_at: '\d{4}-.+'\n\z/) ]
    ])
  end

  it "adds a new record without changing the other records' lines" do
    after = session('Post.create!(author: Author.first, title: "Tehanu")')

    expect(after["posts.yml"]).to include("posts_3:\n  id: 3\n")
    expect(after["posts.yml"].sub(/^posts_3:\n(?:  .*\n)*/, "")).to eq(@before["posts.yml"])
  end

  it "removes the file of a table whose rows are all deleted" do
    after = session("Post.delete_all")

    expect(after.keys).to eq(%w[authors.yml])
    expect(after["authors.yml"]).to eq(@before["authors.yml"])
  end
end
