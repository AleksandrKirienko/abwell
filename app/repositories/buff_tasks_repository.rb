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
end
