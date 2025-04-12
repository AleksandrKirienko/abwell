# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::ProfileInfo do
  subject(:handler) { described_class.new(message_text, chat_id) }

  let(:message_id) { 3442839 }
  let(:chat_id) { 102 }
  let(:message_text) { "[id37606453|Александр], Ваш профиль:<br>👤Класс: апостол (9), гоблин-эльф<br>👥Гильдия:" }

  let(:extracted_voice_count) { 9 }
  let(:initial_voice_count) { 0 }

  let(:vk_id) { 37606453 }

  let!(:game_account) { create :game_account, vk_id: vk_id }

  let!(:apostol_profile) do
    create(:apostol_profile, :human, chat_id: chat_id,
                                     game_account: game_account,
                                     voice_count: initial_voice_count)
  end

  describe '#call' do
    it "changes voice count to expected" do
      handler.call

      expect(apostol_profile.reload.voice_count).to eq extracted_voice_count
    end
  end
end
