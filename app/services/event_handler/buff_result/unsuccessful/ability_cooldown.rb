# frozen_string_literal: true

# Buff cooldown of apostol nod exceeded, so apostol #last_buff_given_at going to be updated
#
module EventHandler::BuffResult::Unsuccessful
  class AbilityCooldown < Base
    def call
      return unless apostol_profile

      apostol_profile.update(last_buff_given_at: Time.current)
    end
  end
end
