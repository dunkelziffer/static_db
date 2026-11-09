class Note < ApplicationRecord
  default_scope { where(archived: false) }

  validates :title, presence: true
end
