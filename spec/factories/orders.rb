FactoryGirl.define do
  factory :order do

    order_number { SecureRandom.hex }
    payment_method { SecureRandom.hex }
    total_amount 1.50
    status { Order::OPEN }
    user

    trait(:successfully_paid) do
      status { Order::SUCCESSFULLY_PAID }
      transaction_id { SecureRandom.hex }
    end

  end
end
