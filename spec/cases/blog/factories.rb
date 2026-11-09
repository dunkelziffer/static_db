FactoryBot.define do
  factory :author do
    sequence(:name) { |n| "Author #{n}" }
  end

  factory :post do
    author
    sequence(:title) { |n| "Post #{n}" }
  end
end
