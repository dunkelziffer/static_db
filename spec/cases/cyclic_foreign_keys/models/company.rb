class Company < ApplicationRecord
  belongs_to :ceo, class_name: "Person", optional: true
  has_many :teams
end
