# frozen_string_literal: true

class EventHandler::ProfileInfo
  attr_reader :message_text, :bot_chat_id

  def initialize(message_text, bot_chat_id)
    @message_text = message_text
    @bot_chat_id = bot_chat_id
  end

  def call
    apostol_profile.update(voice_count: message_parser.extract_voice_count)
  end

  def apostol_profile
    ApostolProfile.joins(:game_account)
                  .find_by(game_accounts: { vk_id: message_parser.extract_id }, bot_chat_id: bot_chat_id)
  end

  def message_parser
    Parsers::ProfileInfoMessageParser.new(message_text)
  end
end





# Parsers::ProfileInfoMessageParser.new(message_text)
