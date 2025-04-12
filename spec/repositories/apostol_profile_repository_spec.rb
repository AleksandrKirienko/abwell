# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApostolProfileRepository do
  let(:repository) { described_class.new(appropriate_bot_chat_id) }
  let(:appropriate_bot_chat_id) { 3 }
  let(:inappropriate_bot_chat_id) { 2 }

  describe '#get_appropriate' do
    context 'when no race is specified' do
      before do
        time = Time.current.beginning_of_minute
        Timecop.freeze(time)

        # Apo with oldest timeout but with another chat_id
        create(:apostol_profile, :with_tasks,
               bot_chat_id: inappropriate_bot_chat_id,
               voice_count: 6,
               tasks_count: 3,
               last_buff_given_at: time - 300.seconds)

        # Первый апостол: 2 голоса больше, чем задач, старый таймаут
        create(:apostol_profile, :with_tasks,
               bot_chat_id: appropriate_bot_chat_id,
               voice_count: 5,
               tasks_count: 3,
               last_buff_given_at: time - 200.seconds)

        # Второй апостол: 1 голос больше, чем задач, новый таймаут
        create(:apostol_profile, :with_tasks,
               voice_count: 4,
               tasks_count: 3,
               last_buff_given_at: time - 50.seconds)

        # Третий апостол: нет свободных голосов
        create(:apostol_profile, :with_tasks,
               voice_count: 3,
               tasks_count: 3,
               last_buff_given_at: time - 200.seconds)
      end

      after do
        Timecop.return
      end

      it 'returns the apostol profile with available voices and oldest timeout' do
        result = repository.get_appropriate

        expect(result.voice_count).to eq(5)
        expect(result.buff_tasks.count).to eq(3)
        expect(result.last_buff_given_at).to eq(Time.current - 200.seconds)
      end

      context 'when no profiles without timeout available' do
        before do
          time = Time.current
          ApostolProfile.update_all(last_buff_given_at: time - 50.seconds)
        end

        it 'returns profile with earliest timeout' do
          result = repository.get_appropriate

          expect(result.voice_count).to eq(5)
          expect(result.buff_tasks.count).to eq(3)
          expect(result.last_buff_given_at).to eq(Time.current - 50.seconds)
        end
      end
    end

    context 'when race is specified' do
      let(:repository) { described_class.new(BuffType::ELF) }

      before do
        time = Time.current.beginning_of_minute
        Timecop.freeze(time)

        # Апостол с нужной расой, старый таймаут
        create(:apostol_profile, :with_tasks,
               voice_count: 5,
               tasks_count: 3,
               last_buff_given_at: time - 200.seconds,
               races: [BuffType::ELF])

        # Апостол с нужной расой, новый таймаут
        create(:apostol_profile, :with_tasks,
               voice_count: 6,
               tasks_count: 3,
               last_buff_given_at: time - 50.seconds,
               races: [BuffType::ELF])

        # Апостол с другой расой
        create(:apostol_profile, :with_tasks,
               voice_count: 7,
               tasks_count: 3,
               last_buff_given_at: time - 200.seconds,
               races: [BuffType::HUMAN])
      end

      after do
        Timecop.return
      end

      it 'returns the apostol profile with specified race and oldest timeout' do
        result = repository.get_appropriate

        expect(result.races).to include(BuffType::ELF)
        expect(result.last_buff_given_at).to eq(Time.current - 200.seconds)
      end

      context 'when no profiles with specified race without timeout' do
        before do
          time = Time.current
          ApostolProfile.where(races: [BuffType::ELF])
                        .update_all(last_buff_given_at: time - 50.seconds)
        end

        it 'returns profile with specified race and earliest timeout' do
          result = repository.get_appropriate

          expect(result.races).to include(BuffType::ELF)
          expect(result.last_buff_given_at).to eq(Time.current - 50.seconds)
        end
      end

      context 'when no apostol with specified race exists' do
        let(:repository) { described_class.new(BuffType::DAEMON) }

        it 'returns nil' do
          expect(repository.get_appropriate).to be_nil
        end
      end
    end
  end
end
