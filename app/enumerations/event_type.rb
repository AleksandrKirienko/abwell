# frozen_string_literal: true

class EventType < EnumerateIt::Base
  associate_values(
    message_editing: 2,
    message_deleting: 3,
    message_new: 4,
  )

  def self.is_message_new?(type)
    type == self::MESSAGE_NEW
  end
end
