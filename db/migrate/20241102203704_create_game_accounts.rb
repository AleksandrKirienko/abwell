# frozen_string_literal: true

class CreateGameAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :game_accounts do |t|
      t.integer :vk_id, null: false
      t.integer :buffs_received, null: false, default: 0

      t.timestamps
    end
  end
end
