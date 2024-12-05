# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuffResultMessageHandler do
  subject(:handler) { described_class.new(message_text) }

  let(:message_text) do
    "✨[id37606453|Александр], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀(24%) Критический баф!<br>🗣Голос у Апостола: 17"
  end

  let(:initial_voice_count) { 18 }

  let(:expected_voice_count) { 17 }
  let(:expected_receiver_vk_id) { 37606453 }
  let(:expected_buff_type) { BuffType::ATTACK }

  let!(:game_account) { create(:game_account, vk_id: 37606453) }
  let!(:apostol_profile) { create(:apostol_profile, voice_count: initial_voice_count) }
  let!(:buff_task) do
    create(:buff_task,
           :attack,
           game_account: game_account,
           apostol_profile: apostol_profile,
           resolved: false)
  end

  describe '#call' do
    it 'resolves buff task' do
      expect { handler.call }.to change { buff_task.reload.resolved }.from(false).to(true)
    end

    it 'updates apostol voice count' do
      expect { handler.call }.to change { apostol_profile.reload.voice_count }
                             .from(initial_voice_count).to(expected_voice_count)
    end

    it 'increments buffs_given counter' do
      expect { handler.call }.to change { apostol_profile.reload.buffs_given }.by(1)
    end

    it 'increments buffs_received counter' do
      expect { handler.call }.to change { game_account.reload.buffs_received }.by(1)
    end

    it 'performs all updates in transaction' do
      allow(ActiveRecord::Base).to receive(:transaction).and_yield
      handler.call
      expect(ActiveRecord::Base).to have_received(:transaction)
    end
  end

  describe '#receiver_vk_id' do
    it 'returns vk_id from message' do
      expect(handler.receiver_vk_id).to eq(expected_receiver_vk_id)
    end
  end

  describe '#buff_type' do
    it 'returns buff type from message' do
      expect(handler.buff_type).to eq(expected_buff_type)
    end
  end

  describe '#voice_count' do
    it 'returns voice count from message' do
      expect(handler.voice_count).to eq(expected_voice_count)
    end
  end

  describe '#buff_task' do
    it 'finds unresolved buff task by game_account_id and buff_type' do
      expect(handler.buff_task).to eq(buff_task)
    end

    context 'when buff task is already resolved' do
      before { buff_task.update(resolved: true) }

      it 'returns nil' do
        expect(handler.buff_task).to be_nil
      end
    end

    context 'when buff task does not exist' do
      before { buff_task.destroy }

      it 'returns nil' do
        expect(handler.buff_task).to be_nil
      end
    end
  end

  describe '#message_parser' do
    it 'returns BuffResultMessageParser instance' do
      expect(handler.message_parser).to be_a(BuffResultMessageParser)
    end

    it 'memoizes parser instance' do
      parser = handler.message_parser
      expect(handler.message_parser).to eq(parser)
    end
  end
end
