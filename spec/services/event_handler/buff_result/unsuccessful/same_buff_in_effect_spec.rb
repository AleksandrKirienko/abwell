# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::BuffResult::Unsuccessful::SameBuffInEffect do
  subject(:handler) { described_class.new(message_text, chat_id) }

  let(:chat_id) { 111 }
  let(:vk_id) { 37606453 }
  let(:message_text) { "🚫[id#{vk_id}|Александр], этот бафф уже активен на цели!" }

  let(:apostol_profile) do
    create(:apostol_profile,
           bot_chat_id: chat_id,
           game_account: create(:game_account, vk_id: vk_id))
  end

  let!(:unresolved_task) do
    create(:buff_task,
           apostol_profile: apostol_profile,
           resolved: false)
  end

  let(:buff_tasks_repository) { instance_double(BuffTasksRepository) }

  describe '#call' do
    context 'when there is an unresolved buff task for the apostol' do
      it 'resolves the unresolved buff task' do
        expect { handler.call }.to change { unresolved_task.reload.resolved }.from(false).to(true)
      end
    end

    context 'when there is no unresolved buff task for the apostol' do
      it 'does not raise an error' do
        expect { handler.call }.not_to raise_error
      end
    end
  end
end
