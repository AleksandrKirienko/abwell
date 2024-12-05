# frozen_string_literal: true

class BuffTask < ApplicationRecord
  belongs_to :game_account
  belongs_to :apostol_profile

  validates :buff_type, presence: true

  validates :game_account_id, uniqueness: {
    scope: [:buff_type, :resolved],
    conditions: -> { where(resolved: false) },
    message: 'already has an unresolved buff task of this type'
  }

  def resolve
    update(resolved: true)
  end
end
