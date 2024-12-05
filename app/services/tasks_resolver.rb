# frozen_string_literal: true

class TasksResolver
  def call
    tasks_for_available_apos = buff_tasks_repository.get_oldest_unresolved_tasks_for_available_apostols

    tasks_for_available_apos.each do |task|
      give_a_buff(task)
    end
  end

  def buff_tasks_repository
    BuffTasksRepository.new
  end

  def give_a_buff(task)
    api.send_message(
      chat_id: 2000000000 + task.apostol_profile.chat_id,
      random_id: rand(10000..99999),
      message:  buff_text(task),
    )
  end

  def buff_text(task)
    "Благословение #{humanized_buff_type(task.buff_type)}"
  end

  def humanized_buff_type(buff_type)
    BuffType::STRING_TO_BUFF.key(buff_type)
  end

  def api
    Api::VkClient.new
  end
end
