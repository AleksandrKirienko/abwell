# frozen_string_literal: true

class ApostolProfile < ApplicationRecord
  encrypts :access_token

  belongs_to :game_account
  has_many :buff_tasks

  validates :voice_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :buffs_given, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :races, presence: true, if: -> { races.present? }
end
