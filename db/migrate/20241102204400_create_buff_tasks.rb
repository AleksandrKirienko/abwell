# frozen_string_literal: true

class CreateBuffTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :buff_tasks do |t|
      t.references :game_account, null: false, foreign_key: true
      t.references :apostol_profile, null: false, foreign_key: true
      t.integer :buff_type, null: false, default: 0
      t.integer :request_message_id, null: false
      t.boolean :resolved, default: false

      t.timestamps
    end
  end
end
