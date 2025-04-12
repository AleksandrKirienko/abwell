# frozen_string_literal: true

# Apostol has no requested race,
#   so all unresolved tasks with race that no in apostol pull are going to be deleted
#
module EventHandler::BuffResult::Unsuccessful
  class InvalidRace < Base
    def call
      return if apostol_buff_tasks_with_invalid_races.empty?

      apostol_buff_tasks_with_invalid_races.each(&:resolve)
    end

    def apostol_buff_tasks_with_invalid_races
      invalid_races = BuffType.invalid_races(apostol_profile.races)

      buff_tasks_repository.get_unresolved_by_apostol_profile_id_and_races(apostol_profile.id, invalid_races)
    end
  end
end
