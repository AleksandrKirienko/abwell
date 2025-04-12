# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventHandler::All do
  subject(:handler) { described_class.new(event) }

  let(:requester_id) { 37606453 }
  let(:chat_name) { "Мирные Кабанчики" }
  let(:apostol_vk_id) { 87654321 }
  let(:warden_vk_id) { described_class::WARDEN_ACCOUNT_ID }
  let(:chat_id) { 2000000102 }
  let(:expected_event_type) { EventType::MESSAGE_NEW }
  let(:unexpected_event_type) { EventType::MESSAGE_EDITING }
  let(:event_type) { expected_event_type }
  let(:message_id) { 3442844 }
  let(:flags) { 532481 }
  let(:timestamp) { 1731752495 }
  let(:meta) do
    { "emoji" => "1", "client_platform_info" => "mAHNE9kCzgBiIIkDAATC", "from" => from_vk_id }
  end
  let(:message_text) { "✨[id#{requester_id}|Александр], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀(24%) Критический баф!<br>🗣Голос у Апостола: 17" }
  let(:from_vk_id) { warden_vk_id }
  let(:event) do
    [event_type, message_id, flags, chat_id, timestamp, chat_name, message_text, meta]
  end


  RSpec.shared_examples "returns nil" do
    it "returns nil" do
      expect(handler.call).to be_nil
    end
  end

  describe "#call" do
    context "when event is not trackable" do
      context "when unexpected event_type" do
        let(:event_type) { unexpected_event_type }

        it_behaves_like 'returns nil'
      end

      context "when message_text doesnt present" do
        let(:message_text) { nil }

        it_behaves_like 'returns nil'
      end

      context "when chat is not trackable" do
        let(:chat_name) { "No matter name" }

        it_behaves_like 'returns nil'
      end
    end

    context "when event is a buff request" do
      let(:from_vk_id) { requester_id }
      let(:message_text) { "/чазу" }
      let(:buff_request_handler) { instance_double(EventHandler::BuffRequest) }

      before do
        allow(EventHandler::BuffRequest).to receive(:new)
                                              .with(message_text, message_id, from_vk_id, chat_id)
                                              .and_return(buff_request_handler)
        allow(buff_request_handler).to receive(:call)
      end

      it "calls EventHandler::BuffRequest" do
        handler.call
        expect(buff_request_handler).to have_received(:call)
      end
    end

    context "when event is a buff result" do
      let(:successful_message_text) { "✨[id#{requester_id}|Александр], на Вас наложено благословение атаки! Атака повышена на 30% в течение двух часов. 🍀(24%) Критический баф!<br>🗣Голос у Апостола: 17" }
      let(:voices_exhausted_message_text) { "🚫[id#{apostol_vk_id}|Григорий], для наложения социальных эффектов - требуется Голос Древних, получаемый при каждой победе над созданиями тьмы!" }
      let(:same_buff_in_effect_message_text) { "✨[id#{requester_id}|Александр], на эту цель уже действует такое благословение!" }
      let(:ability_cooldown_message_text) { "✨[id#{requester_id}|Александр], социальные эффекты можно накладывать только через определенное время после предыдущего!" }
      let(:race_buff_in_effect_message_text) { "✨[id#{requester_id}|Александр], на цель уже наложено другое расовое благословение! Оставшееся время: 47 сек." }
      let(:invalid_race_message_text) { "✨[id#{requester_id}|Александр], Вы не являетесь апостолом этой расы!" }

      let(:buff_result_handler) { instance_double(EventHandler::BuffResult::All) }

      RSpec.shared_examples "handles buff result" do
        before do
          allow(EventHandler::BuffResult::All).to receive(:new)
                                               .with(message_text, result_type, chat_id)
                                               .and_return(buff_result_handler)
          allow(buff_result_handler).to receive(:call)
        end

        it "calls EventHandler::BuffResult::All with result_type" do
          handler.call
          expect(buff_result_handler).to have_received(:call)
        end
      end

      context "when result type - successful" do
        let(:result_type) { :successful }
        let(:message_text) { successful_message_text }

        it_behaves_like "handles buff result"
      end

      context "when result type - voices_exhausted" do
        let(:result_type) { :voices_exhausted }
        let(:message_text) { voices_exhausted_message_text }

        it_behaves_like "handles buff result"
      end

      context "when result type - same_buff_in_effect" do
        let(:result_type) { :same_buff_in_effect }
        let(:message_text) { same_buff_in_effect_message_text }

        it_behaves_like "handles buff result"
      end

      context "when result type - ability_cooldown" do
        let(:result_type) { :ability_cooldown }
        let(:message_text) { ability_cooldown_message_text }

        it_behaves_like "handles buff result"
      end

      context "when result type - race_buff_in_effect" do
        let(:result_type) { :race_buff_in_effect }
        let(:message_text) { race_buff_in_effect_message_text }

        it_behaves_like "handles buff result"
      end

      context "when result type - invalid_race" do
        let(:result_type) { :invalid_race }
        let(:message_text) { invalid_race_message_text }

        it_behaves_like "handles buff result"
      end

      context "when result message not from warden" do
        let(:from_vk_id) { 23112341 }

        before { handler.call }

        it_behaves_like "returns nil"
      end
    end

    context "when event is a profile info" do
      let(:message_text) { "[id#{requester_id}|Александр], Ваш профиль:<br>👤Класс: апостол (9), гоблин-эльф<br>👥Гильдия: Мирные кабанчики<br>😇Очень положительная карма<br>💀Уровень: 302<br>🎉Достижений: 48<br>🌕1785304 💎275<br>👊551 🖐1352 ❤946 🍀62 🗡460 🛡304" }
      let(:profile_info_handler) { instance_double(EventHandler::ProfileInfo) }

      before do
        allow(EventHandler::ProfileInfo).to receive(:new).with(message_text, chat_id).and_return(profile_info_handler)
        allow(profile_info_handler).to receive(:call)
      end

      it "calls EventHandler::BuffResult::All" do
        handler.call
        expect(profile_info_handler).to have_received(:call)
      end
    end
  end
end
