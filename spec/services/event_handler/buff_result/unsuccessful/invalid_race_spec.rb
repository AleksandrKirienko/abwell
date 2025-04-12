# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::BuffResult::Unsuccessful::InvalidRace do
  subject(:handler) { described_class.new(message_text, chat_id) }

  let(:chat_id) { 111 }
  let(:vk_id) { 37606453 }
  let(:message_text) { "🚫[id#{vk_id}|Александр], Вы не являетесь апостолом этой расы!" }
  let(:apostol_races) { [BuffType::HUMAN, BuffType::ELF] }

  let!(:apostol_profile) do
    create(:apostol_profile,
           bot_chat_id: chat_id,
           races: apostol_races,
           game_account: create(:game_account, vk_id: vk_id))
  end

  let!(:valid_task) do
    create(:buff_task,
           apostol_profile: apostol_profile,
           game_account: apostol_profile.game_account,
           buff_type: BuffType::HUMAN,
           resolved: false)
  end

  let!(:invalid_task_1) do
    create(:buff_task,
           apostol_profile: apostol_profile,
           game_account: apostol_profile.game_account,
           buff_type: BuffType::ORC,
           resolved: false)
  end

  let!(:invalid_task_2) do
    create(:buff_task,
           apostol_profile: apostol_profile,
           game_account: apostol_profile.game_account,
           buff_type: BuffType::DWARF,
           resolved: false)
  end

  describe '#call' do
    context 'when there are unresolved tasks with invalid races' do
      it 'resolves tasks with invalid races' do
        expect { handler.call }
          .to change { invalid_task_1.reload.resolved }.from(false).to(true)
                                                       .and change { invalid_task_2.reload.resolved }.from(false).to(true)
      end

      it 'does not resolve tasks with valid races' do
        expect { handler.call }.not_to change { valid_task.reload.resolved }
      end
    end

    context 'when there are no unresolved tasks with invalid races' do
      before do
        invalid_task_1.update!(resolved: true)
        invalid_task_2.update!(resolved: true)
      end

      it 'does not change the state of any tasks' do
        expect { handler.call }.not_to change { valid_task.reload.resolved }
      end
    end
  end

  describe '#apostol_buff_tasks_with_invalid_races' do
    it 'returns unresolved tasks with invalid races' do
      result = handler.send(:apostol_buff_tasks_with_invalid_races)
      expect(result).to match_array([invalid_task_1, invalid_task_2])
    end

    it 'does not return tasks with valid races' do
      result = handler.send(:apostol_buff_tasks_with_invalid_races)
      expect(result).not_to include(valid_task)
    end
  end
end
