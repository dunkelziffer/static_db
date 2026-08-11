class Post < ApplicationRecord
  belongs_to :author

  validates :title, presence: true
end
