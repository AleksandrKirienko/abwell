# frozen_string_literal: true

# Buff task already no needed because such type of buff already applied on receiver
#   so it going to be deleted
#
module EventHandler::BuffResult::Unsuccessful
  class SameBuffInEffect < Base
    def call
      apostol_unnecessary_buff_task.resolve
    end

    private

    def apostol_unnecessary_buff_task
      buff_tasks_repository.get_oldest_unresolved_task_for_apostol(apostol_profile.id)
    end
  end
end
