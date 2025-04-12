# frozen_string_literal: true

class BuffTasksRepository
  APOSTOL_TIMEOUT = 90 # seconds

  def get_oldest_unresolved_tasks_for_available_apostols
    BuffTask
      .joins(:apostol_profile)
      .where(resolved: false)
      .where("apostol_profiles.last_buff_given_at <= ?", APOSTOL_TIMEOUT.seconds.ago)
      .select("DISTINCT ON (buff_tasks.apostol_profile_id) buff_tasks.*")
      .order("buff_tasks.apostol_profile_id, buff_tasks.created_at ASC")
  end

  def get_oldest_unresolved_task_for_apostol(apostol_id)
    BuffTask.where(apostol_profile_id: apostol_id, resolved: false)
            .order(created_at: :asc)
            .first
  end

  def get_all_unresolved_for_apostol(apostol_id)
    BuffTask.where(apostol_profile: apostol_id)
            .where(resolved: false)
  end

  def get_by_account_id_chat_id_and_buff_type(game_account_id, bot_chat_id, buff_type)
    BuffTask.includes(:apostol_profile, :game_account)
            .where(apostol_profiles: { bot_chat_id: bot_chat_id },
                   game_account_id: game_account_id,
                   buff_type: buff_type,
                   resolved: false)
            .first
  end


  def get_unresolved_by_apostol_profile_id_and_races(apostol_profile_id, races)
    BuffTask.where(resolved: false, apostol_profile_id: apostol_profile_id, buff_type: races)
  end
end


