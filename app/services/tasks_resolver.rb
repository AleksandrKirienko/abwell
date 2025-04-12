# frozen_string_literal: true

class TasksResolver
  include LoggerHelper

  def call
    logger.info("TasksResolver called")

    tasks_for_available_apos = buff_tasks_repository.get_oldest_unresolved_tasks_for_available_apostols

    logger.info("No tasks for resolve founded ") if tasks_for_available_apos.empty?
    # logger.info("Founded tasks for resolve count: #{tasks_for_available_apos.all.count}; ids: #{tasks_for_available_apos.all.map(&:id)}")

    tasks_for_available_apos.each do |task|
      logger.info("Founded task:\nid: #{task.id};\naccount_id: #{task.game_account_id};\nbuff_type: #{task.buff_type};\nis_resolved: #{task.resolved};")
    end

    tasks_for_available_apos.each do |task|
      give_a_buff(task)
      update_last_buff_given_ts(task)
    end
  end

  def buff_tasks_repository
    BuffTasksRepository.new
  end

  def give_a_buff(task)
    apostol_profile = task.apostol_profile

    logger.info("Founded Apostol has last_buff_given_at: #{apostol_profile&.last_buff_given_at}")

    api_client(apostol_profile.access_token)
      .send_message(buff_text(task), apostol_profile.chat_id, reply_to: task.request_message_id.to_s)
    # rescue StandardError => error
  #   notifier([task.buff_type], task.request_message_id, apostol_profile.chat_id)
  end

  def update_last_buff_given_ts(task)
    all_apostol_profiles(task).update!(last_buff_given_at: Time.zone.now)
  end

  def buff_text(task)
    "Благословение #{humanized_buff_type(task.buff_type)}"
  end

  def humanized_buff_type(buff_type)
    BuffType::STRING_TO_BUFF.key(buff_type)
  end

  def api_client(token)
    Api::VkClient.new(token)
  end

  def all_apostol_profiles(buff_task)
    @all_apostol_profiles ||= buff_task.apostol_profile.game_account.apostol_profiles
  end
  #
  # def notifier(missing_buffs, message_id, bot_chat_id)
  #   MissingBuffsNotifier.new()
  # end
end

