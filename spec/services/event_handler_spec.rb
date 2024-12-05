# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler do
  let(:sender_id) { 37606453 }
  let(:chat_name) { "Мирные Кабанчики" }
  let(:buff_result_message) do
    [4, 3442844, 532481, 2000000102, 1731752495, chat_name,
     "✨[id37606453|Александр], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀(24%) Критический баф!<br>🗣Голос у Апостола: 17",
     {"emoji"=>"1", "client_platform_info"=>"mAHNE9kCzgBiIIkDAATC", "from"=>"-183040898"}]
  end

  describe '#initialize' do
    let(:event) do
      [4, 3442839, 8227, 2000000102, 1731752478, chat_name, "/чазу",
       {"client_platform_info" => "mAHNFHwCzgAistMDAATC", "from" => sender_id.to_s}]
    end

    subject(:handler) { described_class.new(event) }

    it 'correctly sets attributes from event data' do
      expect(handler.event_type).to eq(4)
      expect(handler.message_id).to eq(3442839)
      expect(handler.chat_id).to eq(2000000102)
      expect(handler.message_timestamp).to eq(1731752478)
      expect(handler.chat_name).to eq(chat_name)
      expect(handler.message_text).to eq("/чазу")
      expect(handler.sender_id).to eq(sender_id)
    end
  end

  describe '#call' do
    subject(:handler) { described_class.new(event) }

    context 'when event is not trackable' do
      let(:event) do
        [4, 3442839, 8227, 2000000102, 1731752478, "Неизвестный чат", "/чазу",
         {"from" => sender_id.to_s}]
      end

      it 'returns nil' do
        expect(handler.call).to be_nil
      end
    end

    context 'when event is a buff request' do
      let(:event) do
        [4, 3442839, 8227, 2000000102, 1731752478, chat_name, "/чазу",
         {"from" => sender_id.to_s}]
      end
      let(:buff_request_handler) { instance_double(BuffRequestMessageHandler) }

      before do
        allow(BuffRequestMessageHandler).to receive(:new)
                                              .with("/чазу", 3442839, sender_id, 2000000102)
                                              .and_return(buff_request_handler)
        allow(buff_request_handler).to receive(:call)
      end

      it 'calls BuffRequestMessageHandler' do
        handler.call
        expect(buff_request_handler).to have_received(:call)
      end
    end

    context 'when event is a buff result' do
      let(:event) { buff_result_message }
      let(:buff_result_handler) { instance_double(BuffResultMessageHandler) }

      before do
        allow(BuffResultMessageHandler).to receive(:new).with(handler.message_text).and_return(buff_result_handler)
        allow(buff_result_handler).to receive(:call)
      end

      it 'calls BuffResultMessageHandler' do
        handler.call
        expect(buff_result_handler).to have_received(:call)
      end
    end
  end

  describe '#event_trackable?' do
    subject(:handler) { described_class.new(event) }

    context 'when event is a new message in tracked chat' do
      let(:is_message_new) { true }
      let(:event) do
        [4, 3442839, 8227, 2000000102, 1731752478, chat_name, "/чазу",
         {"from" => sender_id.to_s}]
      end

      it { expect(handler.event_trackable?).to be true }
    end

    context 'when event is not a new message' do
      let(:is_message_new) { false }
      let(:event) do
        [6, 3442839, 8227, 2000000102, 1731752478, chat_name, "/чазу",
         {"from" => sender_id.to_s}]
      end

      it { expect(handler.event_trackable?).to be false }
    end

    context 'when chat is not tracked' do
      let(:is_message_new) { true }
      let(:event) do
        [4, 3442839, 8227, 2000000102, 1731752478, "Неизвестный чат", "/чазу",
         {"from" => sender_id.to_s}]
      end

      it { expect(handler.event_trackable?).to be false }
    end
  end

  describe '#is_buff_request?' do
    subject(:handler) { described_class.new(event) }

    context 'with valid buff requests' do
      {
        "/азу" => true,
        "/чазу" => true,
        "/зу" => true,
        "/у" => true,
        "/а" => true,
        "/з" => true,
        "/эазу" => true,
        "/чазу" => true,
        "/гзу" => true,
        "/мазу" => true,
        "/оазу" => true,
        "/дазу" => true,
        "/назу" => true
      }.each do |message, expected|
        context "when message is '#{message}'" do
          let(:event) do
            [4, 3442839, 8227, 2000000102, 1731752478, chat_name, message,
             {"from" => sender_id.to_s}]
          end

          it { expect(handler.is_buff_request?).to eq(expected) }
        end
      end
    end

    context 'with invalid buff requests' do
      [
        "/invalid",
        "азу",
        "/азук",
        "/1азу",
        "/азу1",
        "/ азу",
        "/азу ",
        ""
      ].each do |message|
        context "when message is '#{message}'" do
          let(:event) do
            [4, 3442839, 8227, 2000000102, 1731752478, chat_name, message,
             {"from" => sender_id.to_s}]
          end

          it { expect(handler.is_buff_request?).to be false }
        end
      end
    end
  end

  describe '#is_buff_result?' do
    subject(:handler) { described_class.new(event) }

    context 'with valid buff result' do
      let(:event) do
        [4, 3442844, 532481, 2000000102, 1731752495, chat_name,
         "✨[id37606453|Александр], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀(24%) Критический баф!<br>🗣Голос у Апостола: 17",
         {"emoji"=>"1", "client_platform_info"=>"mAHNE9kCzgBiIIkDAATC", "from"=>"-183040898"}]
      end

      it { expect(handler.is_buff_result?).to be true }
    end

    context 'with invalid buff result' do
      let(:event) do
        [4, 3442845, 1, -182985865, 1731752495, chat_name,
         "Какое-то другое сообщение",
         {"from" => sender_id.to_s}]
      end

      it { expect(handler.is_buff_result?).to be false }
    end
  end
end
