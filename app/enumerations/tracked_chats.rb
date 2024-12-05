# frozen_string_literal: true

class TrackedChats < EnumerateIt::Base
  associate_values(
    main_chat: "Мирные Кабанчики",
    newbee_chat: "Боевые Кабанчики"
  )

  def self.include?(chat_name)
    list.include?(chat_name)
  end
end
