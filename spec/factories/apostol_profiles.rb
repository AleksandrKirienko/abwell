FactoryBot.define do
  factory :apostol_profile do
    association :game_account
    voice_count { 3 }
    buffs_given { 0 }
    chat_id { 111 }
    bot_chat_id { 222 }
    races { [1, 2] }
    last_buff_given_at { 2.minutes.ago }
    access_token { SecureRandom.uuid }

    trait :with_tasks do
      transient do
        tasks_count { 1 }
      end

      after(:create) do |apostol_profile, evaluator|
        evaluator.tasks_count.times do |seq|
          create(
            :buff_task,
            apostol_profile: apostol_profile,
            game_account: create(:game_account),
          )
        end
      end
    end

    trait :human do races { [BuffType::HUMAN] }; end
    trait :elf do races { [BuffType::ELF] }; end
    trait :daemon do races { [BuffType::DAEMON] }; end
    trait :undead do races { [BuffType::UNDEAD] }; end
    trait :orc do races { [BuffType::ORC] }; end
    trait :goblin do races { [BuffType::GOBLIN] }; end
    trait :dwarf do races { [BuffType::DWARF] }; end

    trait :not_human do races { [BuffType::ELF] }; end
    trait :not_elf do races { [BuffType::HUMAN] }; end
    trait :not_daemon do races { [BuffType::HUMAN] }; end
    trait :not_undead do races { [BuffType::HUMAN] }; end
    trait :not_orc do races { [BuffType::HUMAN] }; end
    trait :not_goblin do races { [BuffType::HUMAN] }; end
    trait :not_dwarf do races { [BuffType::HUMAN] }; end
  end
end
