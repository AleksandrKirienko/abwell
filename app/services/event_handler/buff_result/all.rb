# frozen_string_literal: true

class EventHandler::BuffResult::All
  attr_reader :message_text, :result_type, :bot_chat_id

  def initialize(message_text, result_type, bot_chat_id)
    @message_text = message_text
    @result_type = result_type
    @bot_chat_id = bot_chat_id
  end

  def call
    handler = BuffAlertFormat.successful?(result_type) ? success_handler : unsuccess_handler

    handler.call
  end

  def success_handler
    EventHandler::BuffResult::Successful.new(message_text, bot_chat_id)
  end

  def unsuccess_handler
    unsuccess_handler_class.new(message_text, bot_chat_id)
  end

  def unsuccess_handler_class
    "EventHandler::BuffResult::Unsuccessful::#{result_type.to_s.camelize}".constantize
  end
end
