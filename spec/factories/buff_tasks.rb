FactoryBot.define do
  factory :buff_task do
    association :game_account
    association :apostol_profile
    buff_type { 0 }
    request_message_id { rand(0..1_000_000) }

    trait :attack do
      buff_type { 7 }
    end

    trait :defense do
      buff_type { 8 }
    end
  end
end
