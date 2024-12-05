# frozen_string_literal: true

class GameAccount < ApplicationRecord
  has_many :apostol_profiles
  has_many :buff_tasks

  validates :vk_id, presence: true
  validates :buffs_received, presence: true, numericality: { only_integer: true,
                                                             greater_than_or_equal_to: 0 }
end
