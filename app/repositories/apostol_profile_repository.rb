# frozen_string_literal: true

class ApostolProfileRepository
  APOSTOL_TIMEOUT = 90

  attr_reader :race, :bot_chat_id

  def initialize(bot_chat_id, race = nil)
    @bot_chat_id = bot_chat_id
    @race = race
  end

  def get_appropriate
    get_appropriate_without_timeout || get_appropriate_with_min_timeout
  end

  def get_appropriate_without_timeout
    subquery =
      initial_scope
        .joins("LEFT JOIN buff_tasks tasks ON tasks.apostol_profile_id = apostol_profiles.id AND tasks.resolved = false")
        .where("apostol_profiles.last_buff_given_at <= ?", APOSTOL_TIMEOUT.seconds.ago)
        .group("apostol_profiles.id, apostol_profiles.voice_count, apostol_profiles.last_buff_given_at, apostol_profiles.bot_chat_id")
        .select("apostol_profiles.*",
                "(apostol_profiles.voice_count - COUNT(tasks.id)) as remaining_voices")

    scope =
      ApostolProfile
        .from("(#{subquery.to_sql}) AS apostol_profiles")
        .where("remaining_voices > 0")
        .order("remaining_voices DESC")

    scope.first
  end

  def get_appropriate_with_min_timeout
    subquery = initial_scope
                 .joins("LEFT JOIN buff_tasks tasks ON tasks.apostol_profile_id = apostol_profiles.id AND tasks.resolved = false")
                 .group("apostol_profiles.id, apostol_profiles.voice_count, apostol_profiles.last_buff_given_at, apostol_profiles.bot_chat_id")
                 .select("apostol_profiles.*",
                         "(apostol_profiles.voice_count - COUNT(tasks.id)) as remaining_voices")

    scope =
      ApostolProfile
        .from("(#{subquery.to_sql}) AS apostol_profiles")
        .where("remaining_voices > 0")
        .order("last_buff_given_at ASC")

    scope.first
  end

  def get_with_unresolved_tasks_without_timeout # need add bot_chat_id
    ApostolProfile
      .joins(:buff_tasks)
      .where(buff_tasks: { resolved: false })
      .where("apostol_profiles.last_buff_given_at <= ?", APOSTOL_TIMEOUT.seconds.ago)
      .select("DISTINCT ON (apostol_profiles.id) apostol_profiles.*, buff_tasks.*")
      .order("apostol_profiles.id, buff_tasks.created_at ASC")
  end

  private

  def initial_scope
    race_scope = race ? ApostolProfile.where("races @> ARRAY[?]::integer[]", race) : ApostolProfile
    race_scope.where(bot_chat_id: bot_chat_id)
  end
end
