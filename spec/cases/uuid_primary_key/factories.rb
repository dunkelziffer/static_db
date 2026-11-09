FactoryBot.define do
  factory :document do
    sequence(:title) { |n| "Document #{n}" }
  end
end
