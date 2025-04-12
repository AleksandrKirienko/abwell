# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::BuffResult::All do
  let(:message_text) { "Текст сообщения" }
  let(:chat_id) { 2000000102 }

  describe '#call' do
    context 'when result is successful' do
      let(:result_type) { BuffAlertFormat.key_for(BuffAlertFormat::SUCCESSFUL) }
      let(:successful_handler) { instance_double(EventHandler::BuffResult::Successful, call: true) }

      subject(:handler) { described_class.new(message_text, result_type, chat_id) }

      before do
        allow(EventHandler::BuffResult::Successful).to receive(:new).with(message_text, chat_id).and_return(successful_handler)
      end

      it 'creates and calls the successful handler' do
        handler.call
        expect(successful_handler).to have_received(:call)
      end
    end

    context 'when result is unsuccessful' do
      BuffAlertFormat.unsuccessful_types.each do |type|
        context "when result type is #{BuffAlertFormat.key_for(type)}" do
          let(:result_type) { BuffAlertFormat.key_for(type) }
          let(:handler_class_name) { "EventHandler::BuffResult::Unsuccessful::#{result_type.to_s.camelize}" }
          let(:unsuccessful_handler) { instance_double(handler_class_name.constantize, call: true) }

          subject(:handler) { described_class.new(message_text, result_type, chat_id) }

          before do
            allow(handler_class_name.constantize).to receive(:new).with(message_text, chat_id).and_return(unsuccessful_handler)
          end

          it "creates and calls the #{BuffAlertFormat.key_for(type)} handler" do
            handler.call
            expect(unsuccessful_handler).to have_received(:call)
          end
        end
      end
    end

    context 'with other result types' do
      let(:result_type) { BuffAlertFormat.key_for(BuffAlertFormat::INVALID_RACE) }
      let(:handler_class_name) { "EventHandler::BuffResult::Unsuccessful::#{result_type.to_s.camelize}" }
      let(:unsuccessful_handler) { instance_double(handler_class_name.constantize, call: true) }

      subject(:handler) { described_class.new(message_text, result_type, chat_id) }

      before do
        allow(handler_class_name.constantize).to receive(:new).with(message_text, chat_id).and_return(unsuccessful_handler)
      end

      it 'creates and calls the appropriate handler' do
        handler.call
        expect(unsuccessful_handler).to have_received(:call)
      end
    end
  end

  describe '#success_handler' do
    let(:result_type) { BuffAlertFormat.key_for(BuffAlertFormat::SUCCESSFUL) }
    subject(:handler) { described_class.new(message_text, result_type, chat_id) }

    it 'returns an instance of EventHandler::BuffResult::Successful' do
      expect(handler.success_handler).to be_an_instance_of(EventHandler::BuffResult::Successful)
    end
  end

  describe '#unsuccess_handler' do
    let(:result_type) { BuffAlertFormat.key_for(BuffAlertFormat::VOICES_EXHAUSTED) }
    let(:handler_class) { EventHandler::BuffResult::Unsuccessful::VoicesExhausted }

    subject(:handler) { described_class.new(message_text, result_type, chat_id) }

    it 'returns an instance of the appropriate unsuccessful handler' do
      expect(handler.unsuccess_handler).to be_an_instance_of(handler_class)
    end
  end

  describe '#unsuccess_handler_class' do
    let(:result_type) { BuffAlertFormat.key_for(BuffAlertFormat::VOICES_EXHAUSTED) }

    subject(:handler) { described_class.new(message_text, result_type, chat_id) }

    it 'returns the correct class for the result type' do
      expect(handler.unsuccess_handler_class).to eq(EventHandler::BuffResult::Unsuccessful::VoicesExhausted)
    end
  end
end
