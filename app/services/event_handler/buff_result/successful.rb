# frozen_string_literal: true

# Buff task successfully applied and need to update some info in DB
#
class EventHandler::BuffResult::Successful
  include LoggerHelper

  attr_reader :message_text, :bot_chat_id

  def initialize(message_text, bot_chat_id)
    @message_text = message_text
    @bot_chat_id = bot_chat_id
  end

  def call
    logger.info("EventHandler::BuffResult::Successful called")
    return unless game_account && buff_task

    logger.info("Task before giving the buff: id: #{buff_task.id};\naccount_id: #{buff_task.game_account_id};\nbuff_type: #{buff_task.buff_type};\nis_resolved: #{buff_task.resolved};")

    ActiveRecord::Base.transaction do
      buff_task.resolve
      all_apostol_profiles.update!(voice_count: voice_count)
      buff_task.apostol_profile.increment!(:buffs_given)
      buff_task.game_account.increment!(:buffs_received)
    rescue StandardError => error
      logger.info!(error)
    end

    logger.info("Task after giving the buff: id: #{buff_task.reload.id};\naccount_id: #{buff_task.reload.game_account_id};\nbuff_type: #{buff_task.reload.buff_type};\nis_resolved: #{buff_task.reload.resolved};")
  end

  private

  def receiver_vk_id
    message_parser.extract_id
  end

  def buff_type
    message_parser.extract_buff_type
  end

  def voice_count
    message_parser.extract_voice_count
  end

  def all_apostol_profiles
    @all_apostol_profiles ||= buff_task.apostol_profile.game_account.apostol_profiles
  end

  def buff_task
    @buff_task ||= buff_tasks_repository
                     .get_by_account_id_chat_id_and_buff_type(game_account.id, bot_chat_id, buff_type)
  end

  def game_account
    @game_account ||= GameAccount.find_by(vk_id: receiver_vk_id)
  end

  def buff_tasks_repository
    @buff_tasks_repository ||= BuffTasksRepository.new
  end

  def message_parser
    @message_parser ||= Parsers::BuffResultMessageParser.new(message_text)
  end
end
