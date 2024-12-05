FactoryBot.define do
  factory :game_account do
    sequence(:vk_id) { |n| n }
    buffs_received { 0 }
  end
end
