# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::BuffResult::Unsuccessful::AbilityCooldown do
  subject(:handler) { described_class.new(message_text, chat_id) }

  let(:chat_id) { 111 }
  let(:message_text) { "🚫[id37606453|Александр], социальные эффекты можно накладывать только через определенное время после предыдущего!" }
  let(:vk_id) { 37606453 }
  let(:time_current) { Time.current.beginning_of_minute }
  let!(:apostol_profile) { create(:apostol_profile, bot_chat_id: chat_id, last_buff_given_at: 1.hour.ago, game_account: create(:game_account, vk_id: vk_id)) }

  before do
    Timecop.freeze(time_current)
  end

  after { Timecop.return }

  describe '#call' do
    context 'when apostol_profile is found' do
      it 'updates last_buff_given_at to current time' do
        handler.call
        expect(apostol_profile.reload.last_buff_given_at).to eq(time_current)
      end
    end

    context 'when apostol_profile is not found' do
      before do
        allow(ApostolProfile).to receive(:joins).and_return(ApostolProfile.none)
      end

      it 'does not raise an error' do
        expect { handler.call }.not_to raise_error
      end
    end
  end

  describe 'message_text format' do
    context 'when ability cooldown message is passed' do
      it 'matches the correct enumerator format' do
        expect(message_text).to match(BuffAlertFormat::ABILITY_COOLDOWN)
      end
    end

    context 'when message does not match any unsuccessful type' do
      let(:message_text) { "🚫[id37606453|Александр], на Вас наложено благословение!" }

      it 'does not match unsuccessful types' do
        expect(BuffAlertFormat.unsuccessful_types.any? { |type| message_text.match(type) }).to be_falsey
      end
    end
  end
end
