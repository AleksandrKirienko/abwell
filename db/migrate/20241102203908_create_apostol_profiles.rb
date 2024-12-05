# frozen_string_literal: true

class CreateApostolProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :apostol_profiles do |t|
      t.references :game_account, null: false, foreign_key: true
      t.integer :voice_count, null: false, default: 0
      t.integer :buffs_given, null: false, default: 0
      t.integer :chat_id, null: false
      t.integer :races, array: true
      t.timestamp :last_buff_given_at

      t.timestamps
    end
  end
end
