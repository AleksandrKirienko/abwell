# frozen_string_literal: true

class EventHandler::All
  BUFF_REQUEST_FORMAT = /^\/[азу]*[эчгмодн]?[азу]*$|^\/[азу]+$/
  PROFILE_INFO_FORMAT = /], Ваш профиль:<br>👤Класс: апостол/

  WARDEN_ACCOUNT_ID = "-183040898"

  attr_reader :event_type, :message_id, :bot_chat_id, :message_timestamp,
              :chat_name, :message_text, :sender_id

  def initialize(event)
    logger.info(event)
    @event_type, @message_id, @_flags, @bot_chat_id,
      @message_timestamp, @chat_name, @message_text, @meta = event

    @sender_id = @meta ? @meta["from"].to_i : nil
  end

  def call
    return unless EventType.is_chat_message?(event_type)
    return unless message_text
    return unless event_trackable?

    show_logs

    if is_buff_request?
      return EventHandler::BuffRequest.new(message_text, message_id, sender_id, bot_chat_id).call
    end

    return EventHandler::ProfileInfo.new(message_text, bot_chat_id).call if is_profile_info?

    result_type = match_buff_result_or_false
    EventHandler::BuffResult::All.new(message_text, result_type, bot_chat_id).call if result_type
  end

  private

  def event_trackable?
    TrackedChats.include?(chat_name)
  end

  def is_buff_request?
    message_text.match?(BUFF_REQUEST_FORMAT)
  end

  def is_profile_info?
    message_text.match?(PROFILE_INFO_FORMAT)
  end

  def match_buff_result_or_false
    return false unless is_warden_message?

    BuffAlertFormat.to_h.each do |pattern_name, pattern_text|
      return pattern_name if message_text.match?(pattern_text)
    end

    false
  end

  def is_warden_message?
    sender_id.to_s == WARDEN_ACCOUNT_ID
  end

  def show_logs
    logger.info([event_type, message_id, bot_chat_id, message_timestamp, chat_name, message_text, sender_id])
    logger.info("IS CHAT MESSAGE ? - #{EventType.is_chat_message?(event_type)}")
    logger.info("IS EVENT TRACKABLE ? - #{event_trackable?}")
    logger.info("IS BUFF REQUEST ? - #{is_buff_request?}")
  end

  def logger
    @logger ||= Sidekiq.logger
  end
end


# request_message = [4, 3442839, 8227, 2000000102, 1731752478, "Мирные Кабанчики", "/чазу", {"client_platform_info"=>"mAHNFHwCzgAistMDAATC", "from"=>"37606453"}]
# buff_message = [4, 3442843, 2105379, 2000000102, 1731752493, "Мирные Кабанчики", "Благословение атаки", {"reply"=>"{\"conversation_message_id\":1365462}", "client_platform_info"=>"mAHNFHwCzgAistMDAATC", "fwd"=>"0_0", "from"=>"37606453"}]
# result_message = [4, 3442845, 1, -182985865, 1731752495, " ... ", "✨На Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀Критический баф!", {"emoji"=>"1"}]
# [4, 11417, 2000000002, 1734463064, "Мирные Кабанчики", "/а"]
# [4, 11417, 2000000002, 1734463064, "Мирные Кабанчики", "/а"]
# 3997581

# id for mess response 1512697
