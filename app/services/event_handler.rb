# frozen_string_literal: true

class EventHandler
  BUFF_REQUEST_FORMAT = /^\/[азу]*[эчгмодн]?[азу]*$|^\/[азу]+$/
  BUFF_RESULT_FORMAT = /на Вас наложено благословение/

  TRACKED_CHATS = ["Мирные Кабанчики", "Боевые Кабанчики"].freeze

  attr_reader :event_type, :message_id, :chat_id, :message_timestamp,
              :chat_name, :message_text, :sender_id

  def initialize(event)
    @sender_id = event.last["from"].to_i

    @event_type, @message_id, @flags, @chat_id,
      @message_timestamp, @chat_name, @message_text = event
  end

  def call
    return unless event_trackable?

    if is_buff_request?
      BuffRequestMessageHandler.new(message_text, message_id, sender_id, chat_id).call
    end

    if is_buff_result?
      BuffResultMessageHandler.new(message_text).call
    end
  end

  def event_trackable?
    EventType.is_message_new?(event_type) && TrackedChats.include?(chat_name)
  end

  def is_buff_request?
    message_text.match?(BUFF_REQUEST_FORMAT)
  end

  def is_buff_result?
    message_text.match?(BUFF_RESULT_FORMAT)
  end
end


# request_message = [4, 3442839, 8227, 2000000102, 1731752478, "Мирные Кабанчики", "/чазу", {"client_platform_info"=>"mAHNFHwCzgAistMDAATC", "from"=>"37606453"}]
# buff_message = [4, 3442843, 2105379, 2000000102, 1731752493, "Мирные Кабанчики", "Благословение атаки", {"reply"=>"{\"conversation_message_id\":1365462}", "client_platform_info"=>"mAHNFHwCzgAistMDAATC", "fwd"=>"0_0", "from"=>"37606453"}]
# result_message = [4, 3442845, 1, -182985865, 1731752495, " ... ", "✨На Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀Критический баф!", {"emoji"=>"1"}]
