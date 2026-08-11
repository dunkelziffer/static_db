module Corpus
  def seed_corpus!
    tolkien = Author.create!(name: "J. R. R. Tolkien")
    le_guin = Author.create!(name: "Ursula K. Le Guin")

    Post.create!(author: tolkien, title: "On Fairy-Stories", body: "Faërie cannot be caught in a net of words.", published: true)
    Post.create!(author: le_guin, title: "The Carrier Bag Theory", body: "A leaf a gourd a shell a net a bag a sling a sack a bottle a pot a box a container.", published: true)
    Post.create!(author: le_guin, title: "Draft", body: nil, published: false)
  end

  def static_db_dir(name = "data")
    path = Pathname.new(Dir.mktmpdir("static_db_spec")).join(name)
    FileUtils.mkdir_p(path)
    path
  end
end

RSpec.configure { |config| config.include Corpus }
