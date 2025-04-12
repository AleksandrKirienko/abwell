# frozen_string_literal: true

class EventType < EnumerateIt::Base
  associate_values(
    message_editing: 2,
    message_deleting: 3,
    message_new: 4,
  )

  def self.is_chat_message?(type)
    type == self::MESSAGE_NEW
  end
end
