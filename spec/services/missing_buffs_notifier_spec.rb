# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MissingBuffsNotifier do
  let(:message_id) { 123 }
  let(:chat_id) { 456 }
  let(:api_client) { instance_double(Api::VkClient) }

  before do
    allow(Api::VkClient).to receive(:new).and_return(api_client)
    allow(api_client).to receive(:send_message)
  end

  describe '#call' do
    context 'when standard buffs missing' do
      let(:missing_buffs) { [BuffType::ATTACK, BuffType::DEFENCE] }
      subject { described_class.new(missing_buffs, message_id, chat_id) }

      it 'notify that voices exhausted' do
        expected_message = "Бафов атаки, защиты не будет.\nУ всех апостолов закончились голоса.\nИспользуйте команду '/апопроф' чтобы актуализировать информацию о голосах у апостолов."

        subject.call

        expect(api_client).to have_received(:send_message).with(expected_message, chat_id, reply_to: message_id)
      end
    end

    context 'when race buff missing' do
      let(:missing_buffs) { [BuffType::HUMAN] }
      subject { described_class.new(missing_buffs, message_id, chat_id) }

      it 'notify that required race apos have no voices' do
        expected_message = "Бафа человека не будет.\nУ апостолов запрашиваемой рассы закончились голоса, либо их вообще нет на автобафе.\nИспользуйте команду '/апопроф' чтобы актуализировать информацию о голосах у апостолов."

        subject.call

        expect(api_client).to have_received(:send_message).with(expected_message, chat_id, reply_to: message_id)
      end
    end
  end
end
