# frozen_string_literal: true

class TrackedChats < EnumerateIt::Base
  associate_values(
    main_chat: "Мирные Кабанчики",
    newbe_chat: "Боевые кабанчики"
  )

  CHAT_NUMBERS_BY_NAME = {
    "Мирные Кабанчики" => 2,
    "Боевые кабанчики" => 3
  }.freeze

  def self.include?(chat_name)
    list.include?(chat_name)
  end

  def self.bot_chat_id_by_name(chat_name)
    CHAT_NUMBERS_BY_NAME[chat_name]
  end
end
