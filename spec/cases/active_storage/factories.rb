FactoryBot.define do
  # Blob keys are random unless given.
  upload = ->(key, content) { { io: StringIO.new(content), filename: "#{key}.txt", key: } }

  factory :profile do
    sequence(:name) { |n| "Profile #{n}" }

    trait :with_avatar do
      avatar { upload["#{name.parameterize}-avatar", "#{name}'s avatar"] }
    end

    trait :with_documents do
      documents { %w[cv notes].map { |doc| upload["#{name.parameterize}-#{doc}", "#{name}'s #{doc}"] } }
    end
  end
end
