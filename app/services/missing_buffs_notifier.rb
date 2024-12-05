# frozen_string_literal: true

class MissingBuffsNotifier
  attr_reader :missing_buffs, :message_id, :chat_id

  def initialize(missing_buffs, message_id, chat_id)
    @missing_buffs = missing_buffs
    @message_id = message_id
    @chat_id = chat_id
  end

  def call
    nil
  end
end
