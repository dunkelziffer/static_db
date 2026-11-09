FactoryBot.define do
  factory :vehicle do
    factory :car, class: "Car"
    factory :bike, class: "Bike"
  end
end
