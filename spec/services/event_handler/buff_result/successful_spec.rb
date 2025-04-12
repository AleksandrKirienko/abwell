require 'rails_helper'

RSpec.describe EventHandler::BuffResult::Successful do
  describe '#call' do
    let(:message_text) { "✨[id123|Игрок], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀(24%) Критический баф!<br>🗣Голос у Апостола: 17" }
    let(:chat_id) { 2000000102 }
    let(:receiver_vk_id) { 123 }
    let(:buff_type) { BuffType::ATTACK }
    let(:voice_count) { 17 }

    let!(:game_account) { create(:game_account, vk_id: receiver_vk_id, buffs_received: 0) }
    let!(:apostol_profile) { create(:apostol_profile, voice_count: 20, buffs_given: 0) }
    let!(:buff_task) { create(:buff_task, buff_type: buff_type, game_account: game_account,
                              apostol_profile: apostol_profile, resolved: false, chat_id: chat_id) }

    subject(:handler) { described_class.new(message_text, chat_id) }

    it 'update the buff task' do
      expect { handler.call }.to change { buff_task.reload.resolved }.from(false).to(true)
                             .and change { apostol_profile.reload.voice_count }.from(20).to(17)
                             .and change { apostol_profile.reload.buffs_given }.by(1)
    end

    it 'increments game_account buffs_received counter' do
      expect { handler.call }.to change { game_account.reload.buffs_received }.by(1)
    end

    it 'performs all operations in a transaction' do
      expect(ActiveRecord::Base).to receive(:transaction).and_call_original
      handler.call
    end

    context 'when game_account is not found' do
      let(:message_text) { "✨[id999|Игрок], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов.<br>🗣Голос у Апостола: 17" }

      it 'raises an error' do
        expect { handler.call }.not_to raise_error
      end
    end

    context 'when buff_task is not found' do
      before do
        buff_task.destroy
      end

      it 'returns nil without making changes' do
        expect(handler.call).to be_nil

        # Check that there was no changes made
        #
        expect(apostol_profile.reload.voice_count).to eq(20)
        expect(apostol_profile.reload.buffs_given).to eq(0)
        expect(game_account.reload.buffs_received).to eq(0)
      end
    end

    context 'with different buff types' do
      let(:message_text) { "✨[id123|Игрок], на Вас наложено благословение защиты! Защита повышена на 30% в течение двух часов.<br>🗣Голос у Апостола: 15" }
      let(:different_buff_type) { BuffType::DEFENCE }

      let!(:defense_buff_task) do
        create(:buff_task, buff_type: different_buff_type, game_account: game_account,
               apostol_profile: apostol_profile, resolved: false, chat_id: chat_id)
      end

      it 'resolves the correct buff task type' do
        expect { handler.call }.to change { defense_buff_task.reload.resolved }.from(false).to(true)
        expect(buff_task.reload.resolved).to be false
      end

      it 'updates apostol_profile with the correct voice count' do
        expect { handler.call }.to change { apostol_profile.reload.voice_count }.from(20).to(15)
      end
    end
  end
end
