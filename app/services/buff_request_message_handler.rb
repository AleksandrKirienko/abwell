# frozen_string_literal: true

class BuffRequestMessageHandler
  attr_reader :message_text, :message_id, :sender_id, :chat_id

  def initialize(message_text, message_id, sender_id, chat_id)
    @message_text = message_text
    @message_id = message_id
    @sender_id = sender_id
    @chat_id = chat_id
  end

  def call
    create_game_account_if_needed

    # TasksPlanner returns array with missing buffs
    #   it happens when any of race apostol not presented,
    #   or apostol_profiles have not enough voices
    #
    missing_buffs = create_tasks

    notify_missing_buffs(missing_buffs, message_id, chat_id)

    # buff will be executed in context of every 10 sec worker
    # update statistics to game_account and apostol_profile
  end

  # Convert string like "чазу" to buff_types hash:
  #
  # {
  #   race_buff: 0,
  #   standard_buffs: [7, 8, 9]
  # }
  #
  def buff_types
    chars = message_text.chars.drop(1)

    BuffType.chars_to_types(chars)
  end

  def create_game_account_if_needed
    GameAccount.first_or_create(vk_id: @sender_id)
  end

  def create_tasks
    TasksPlanner.new(
      race_buff: buff_types[:race_buff],
      standard_buffs: buff_types[:standard_buffs],
      message_id: message_id,
      vk_id: sender_id
    ).call
  end

  def notify_missing_buffs(missing_buffs, message_id, chat_id)
    return if missing_buffs.empty?

    MissingBuffsNotifier.new(missing_buffs, message_id, chat_id).call
  end
end
