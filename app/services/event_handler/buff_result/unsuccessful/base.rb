# frozen_string_literal: true

module EventHandler::BuffResult::Unsuccessful
  class Base
    attr_reader :message_text, :bot_chat_id

    def initialize(message_text, bot_chat_id)
      @message_text = message_text
      @bot_chat_id = bot_chat_id
    end

    def call
      raise NotImplementedError
    end

    private

    def message_parser
      @message_parser ||= Parsers::BuffResultMessageParser.new(message_text)
    end

    def apostol_game_account_id
      message_parser.extract_id
    end

    def apostol_profile
      ApostolProfile.joins(:game_account)
                    .find_by(game_accounts: { vk_id: apostol_game_account_id },
                             bot_chat_id: bot_chat_id)
    end

    def buff_tasks_repository
      @buff_tasks_repository ||= BuffTasksRepository.new
    end
  end
end
