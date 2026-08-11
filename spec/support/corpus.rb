module Corpus
  # Timestamps are fixed and ids come from the per-example sequence reset, so a dump of
  # this corpus is byte-for-byte reproducible and can be compared against a committed
  # golden directory.
  SEEDED_AT = Time.utc(2026, 3, 14, 9, 26, 53, 589_793)

  def seed_corpus!
    preussler = create_author("Otfried Preußler")
    le_guin   = create_author("Ursula K. Le Guin")

    create_post(preussler, "Krabat", "Die Mühle im Koselbruch mahlt nicht nur Korn.", published: true)
    create_post(le_guin, "A Wizard of Earthsea", "Only in silence the word, only in dark the light.", published: true)
    # Body left nil on purpose: Dump omits nil columns, so the golden file records that
    # behaviour rather than letting it pass unnoticed.
    create_post(le_guin, "The Tombs of Atuan", nil, published: false)
  end

  def create_author(name) = Author.create!(name: name, created_at: SEEDED_AT, updated_at: SEEDED_AT)

  def create_post(author, title, body, published:)
    Post.create!(author: author, title: title, body: body, published: published,
                 created_at: SEEDED_AT, updated_at: SEEDED_AT)
  end

  def golden_dir = Rails.root.join("..", "fixtures", "golden").cleanpath

  def static_db_dir(name = "data")
    path = Pathname.new(Dir.mktmpdir("static_db_spec")).join(name)
    FileUtils.mkdir_p(path)
    path
  end
end

RSpec.configure { |config| config.include Corpus }
