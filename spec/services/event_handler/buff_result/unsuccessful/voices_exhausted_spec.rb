# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::BuffResult::Unsuccessful::VoicesExhausted do
  subject(:handler) { described_class.new(message_text, chat_id) }

  let(:chat_id) { 111 }
  let(:vk_id) { 37606453 }
  let(:message_text) { "🚫[id#{vk_id}|Александр], у вас закончились голоса для наложения баффов!" }

  let(:apostol_profile) do
    create(:apostol_profile,
           bot_chat_id: chat_id,
           voice_count: 5,
           game_account: create(:game_account, vk_id: vk_id))
  end

  let!(:unresolved_task_1) do
    create(:buff_task,
           apostol_profile: apostol_profile,
           resolved: false)
  end

  let!(:unresolved_task_2) do
    create(:buff_task,
           apostol_profile: apostol_profile,
           resolved: false)
  end

  let(:buff_tasks_repository) { instance_double(BuffTasksRepository) }

  describe '#call' do
    it 'sets the voice_count of the apostol to 0' do
      expect { handler.call }.to change { apostol_profile.reload.voice_count }.from(5).to(0)
    end

    it 'resolves all unresolved buff tasks for the apostol' do
      expect { handler.call }
        .to change { unresolved_task_1.reload.resolved }.from(false).to(true)
        .and change { unresolved_task_2.reload.resolved }.from(false).to(true)
    end

    it 'executes all changes within a transaction' do
      expect(ActiveRecord::Base).to receive(:transaction).and_call_original

      handler.call
    end
  end
end
