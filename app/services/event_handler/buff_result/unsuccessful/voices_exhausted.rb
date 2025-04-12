# frozen_string_literal: true

# Apostol has no voices to apply any buffs,
#   so all tasks of apostol going to be resolved
#
module EventHandler::BuffResult::Unsuccessful
  class VoicesExhausted < Base
    def call
      ActiveRecord::Base.transaction do
        apostol_profile.update(voice_count: 0)
        apostol_unresolved_buff_tasks.each(&:resolve)
      end
    end

    private

    def apostol_unresolved_buff_tasks
      buff_tasks_repository.get_all_unresolved_for_apostol(apostol_profile.id)
    end
  end
end
