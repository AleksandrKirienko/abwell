# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksResolver do
  subject(:resolver) { described_class.new }

  let(:api) { instance_double(Api::VkClient) }
  let(:chat_id) { 102 }

  before do
    allow(Api::VkClient).to receive(:new).and_return(api)
    allow(api).to receive(:send_message)
  end

  describe '#call' do
    context 'when there are unresolved tasks for available apostols' do
      let!(:apostol1) do
        create(:apostol_profile,
               chat_id: chat_id,
               voice_count: 3,
               buffs_given: 0,
               last_buff_given_at: 2.minutes.ago,
               races: [BuffType::HUMAN, BuffType::ELF])
      end

      let!(:apostol2) do
        create(:apostol_profile,
               chat_id: chat_id,
               voice_count: 3,
               buffs_given: 0,
               last_buff_given_at: 2.minutes.ago,
               races: [BuffType::ORC, BuffType::GOBLIN])
      end

      let!(:unavailable_apostol) do
        create(:apostol_profile, :daemon,
               chat_id: chat_id,
               voice_count: 3,
               buffs_given: 0,
               last_buff_given_at: 30.seconds.ago)
      end

      let!(:task1) do
        create(:buff_task,
               apostol_profile: apostol1,
               buff_type: BuffType::HUMAN,
               created_at: 10.minutes.ago,
               resolved: false)
      end

      let!(:task2) do
        create(:buff_task,
               apostol_profile: apostol2,
               buff_type: BuffType::ATTACK,
               created_at: 7.minutes.ago,
               resolved: false)
      end

      let!(:newer_task) do
        create(:buff_task,
               apostol_profile: apostol1,
               buff_type: BuffType::FORTUNE,
               created_at: 5.minutes.ago,
               resolved: false)
      end

      let!(:resolved_task) do
        create(:buff_task,
               apostol_profile: apostol1,
               buff_type: BuffType::DEFENCE,
               created_at: 15.minutes.ago,
               resolved: true)
      end

      let!(:unavailable_apostol_task) do
        create(:buff_task,
               apostol_profile: unavailable_apostol,
               buff_type: BuffType::DAEMON,
               created_at: 3.minutes.ago,
               resolved: false)
      end

      before do
        allow(resolver).to receive(:rand).and_return(12345)
      end

      it 'sends buff messages only for oldest unresolved tasks of available apostols' do
        resolver.call

        expect(api).to have_received(:send_message)
                         .with("Благословение человека", chat_id, reply_to: task1.request_message_id.to_s)
                         .exactly(1).time
        expect(api).to have_received(:send_message)
                         .with("Благословение атаки", chat_id, reply_to: task2.request_message_id.to_s)
                         .exactly(1).time
      end
    end

    context 'when there are no tasks for available apostols' do
      let!(:unavailable_apostol) do
        create(:apostol_profile, :human, chat_id: chat_id, last_buff_given_at: 30.seconds.ago)
      end

      let!(:unavailable_task) do
        create(:buff_task, buff_type: BuffType::HUMAN, apostol_profile: unavailable_apostol, resolved: false)
      end

      it 'does not send any messages' do
        resolver.call
        expect(api).not_to have_received(:send_message)
      end
    end

    context 'when all tasks are resolved' do
      let!(:apostol) do
        create(:apostol_profile, :human, chat_id: chat_id, last_buff_given_at: 2.minutes.ago)
      end

      let!(:resolved_task) do
        create(:buff_task,
               apostol_profile: apostol,
               buff_type: BuffType::HUMAN,
               resolved: true)
      end

      it 'does not send any messages' do
        resolver.call
        expect(api).not_to have_received(:send_message)
      end
    end
  end

  describe '#buff_text' do
    let(:apostol) do
      create(:apostol_profile, :human, chat_id: chat_id)
    end

    context 'with race buff' do
      let(:task) { build(:buff_task, apostol_profile: apostol, buff_type: BuffType::HUMAN) }

      it 'returns correct buff text' do
        expect(resolver.buff_text(task)).to eq('Благословение человека')
      end
    end

    context 'with standard buff' do
      let(:task) { build(:buff_task, apostol_profile: apostol, buff_type: BuffType::ATTACK) }

      it 'returns correct buff text' do
        expect(resolver.buff_text(task)).to eq('Благословение атаки')
      end
    end
  end

  describe '#humanized_buff_type' do
    it 'returns correct string representation of buff type' do
      expect(resolver.humanized_buff_type(BuffType::HUMAN)).to eq('человека')
      expect(resolver.humanized_buff_type(BuffType::ATTACK)).to eq('атаки')
      expect(resolver.humanized_buff_type(BuffType::FORTUNE)).to eq('удачи')
    end
  end
end
