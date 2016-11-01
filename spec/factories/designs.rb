FactoryGirl.define do
  factory :design do

    image { any_image }
    image_desc { SecureRandom.hex }

    first_garment_design { any_image }
    first_garment_model_design { any_image }
    first_garment_print_design { any_image }
    first_garment_technical_design { any_image }
    first_garment_desc { SecureRandom.hex }

    second_garment_design { any_image }
    second_garment_model_design { any_image }
    second_garment_print_design { any_image }
    second_garment_technical_design { any_image }
    second_garment_desc { SecureRandom.hex }

    third_garment_design { any_image }
    third_garment_model_design { any_image }
    third_garment_print_design { any_image }
    third_garment_technical_design { any_image }
    third_garment_desc { SecureRandom.hex }

    for_competition false
    for_sale false
    price "9.99"
    add_to { SecureRandom.hex }
    competition false
    user nil

  end
end
