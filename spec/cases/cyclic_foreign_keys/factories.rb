FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
  end

  factory :team do
    company
    sequence(:name) { |n| "Team #{n}" }
  end

  factory :person do
    team
    sequence(:name) { |n| "Person #{n}" }
  end
end
