# frozen_string_literal: true

class BuffResultMessageHandler
  DEFAULT_MESSAGE_EXTRACTING_COUNT = 10

  attr_reader :message_text

  def initialize(message_text)
    @message_text = message_text
  end

  def call
    ActiveRecord::Base.transaction do
      buff_task.resolve
      buff_task.apostol_profile.update(voice_count: voice_count)
      buff_task.apostol_profile.increment!(:buffs_given)
      buff_task.game_account.increment!(:buffs_received)
    end
  end

  def receiver_vk_id
    message_parser.extract_id
  end

  def buff_type
    message_parser.extract_buff_type
  end

  def voice_count
    message_parser.extract_voice_count
  end

  def message_parser
    @message_parser ||= BuffResultMessageParser.new(message_text)
  end

  def buff_task
    @buff_task ||= BuffTask.includes(:apostol_profile, :game_account)
                           .find_by(game_account_id: game_account.id,
                                    buff_type: buff_type,
                                    resolved: false)

  end

  def game_account
    @game_account ||= GameAccount.find_by(vk_id: receiver_vk_id)
  end
end
