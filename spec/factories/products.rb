FactoryGirl.define do
  factory :product do
    name { SecureRandom.hex }
    main_image { SpecHelpers.any_image }
    first_thumbnail { SpecHelpers.any_image }
    second_thumbnail { SpecHelpers.any_image }
    third_thumbnail { SpecHelpers.any_image }
    price { (Random.rand * 9 + 1).round(2).to_s }
    description { SecureRandom.hex }
    designer { SecureRandom.hex }
    about_lumumba { SecureRandom.hex }
    about_designer { SecureRandom.hex }
    preview false
    initial_stock 1
  end
end
