# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler::BuffRequest do
  subject(:handler) { described_class.new(request_string, message_id, game_account.vk_id, chat_id) }

  let(:message_id) { 3442839 }
  let(:chat_id) { 102 }
  let(:request_string) { "/чазу" }
  let(:time_current) { Time.current.beginning_of_minute }

  let(:voice_count) { 4 }
  let(:tasks_count) { 2 }

  let(:first_apo_races) { [BuffType::ELF, BuffType::DWARF] }

  let!(:game_account) { create :game_account }

  let(:original_message_id_1) { 111 }
  let!(:apo1) do
    create(:apostol_profile, :with_tasks, races: first_apo_races , chat_id: chat_id,
           voice_count: voice_count, tasks_count: tasks_count, last_buff_given_at: 3.minutes.ago)
  end

  let(:original_message_id_2) { 222 }
  let!(:apo2) do
    create(:apostol_profile, :with_tasks, :not_human, chat_id: chat_id,
           voice_count: voice_count, tasks_count: tasks_count, last_buff_given_at: 2.minutes.ago)
  end

  let(:original_message_id_3) { 333 }
  let!(:apo3) do
    create(:apostol_profile, :with_tasks, :not_human, chat_id: chat_id,
           voice_count: voice_count, tasks_count: tasks_count, last_buff_given_at: 1.minutes.ago)
  end

  let(:api_client) { instance_double(Api::VkClient) }
  let(:api_client_2) { instance_double(Api::VkClient) }
  let(:api_client_3) { instance_double(Api::VkClient) }

  let(:expected_original_message_ids) do
    [original_message_id_1,
     original_message_id_2,
     original_message_id_3]
  end


  def history_fixture(original_message_id)
    { "items" => [{ "from_id" => game_account.vk_id,
                    "text" => request_string,
                    "id" => original_message_id }] }
  end

  let(:buffs_notifier) { instance_double(MissingBuffsNotifier) }

  before do
    Timecop.freeze(time_current)
    allow(MissingBuffsNotifier).to receive(:new)
                               .with(expected_missed_buffs, message_id, chat_id)
                               .and_return(buffs_notifier)
    allow(buffs_notifier).to receive(:call)

    api_client = instance_double(Api::VkClient)
    allow(Api::VkClient).to receive(:new).with(apo1.access_token).and_return(api_client)
    allow(api_client).to receive(:get_chat_history)
                           .with(apo1.chat_id)
                           .and_return(history_fixture(original_message_id_1))

    api_client_2 = instance_double(Api::VkClient)
    allow(Api::VkClient).to receive(:new).with(apo2.access_token).and_return(api_client_2)
    allow(api_client_2).to receive(:get_chat_history)
                             .with(apo2.chat_id)
                             .and_return(history_fixture(original_message_id_2))

    api_client_3 = instance_double(Api::VkClient)
    allow(Api::VkClient).to receive(:new).with(apo3.access_token).and_return(api_client_3)
    allow(api_client_3).to receive(:get_chat_history)
                             .with(apo3.chat_id)
                             .and_return(history_fixture(original_message_id_3))
  end

  after { Timecop.return }

  # with missing buffs: create 3 apos with 3 voices and 2 tasks each OR no one human
  # without missing buffs: create 3 apos with 4 voices and 2 tasks each human presented

  describe "#call" do
    context "when missing buffs are present" do
      context "when race apo presented but not enough voices" do
        let(:voice_count) { 3 }
        let(:expected_missed_buffs) { [BuffType::FORTUNE] }
        let(:api_client) { instance_double(Api::VkClient) }

        let(:expected_original_message_ids) do
          [original_message_id_1,
           original_message_id_2,
           original_message_id_3]
        end

        let(:first_apo_races) { [BuffType::HUMAN] }

        it "creates 3 new buff tasks with expected original_message_id" do
          expect { handler.call }.to change(BuffTask, :count).by(3)
          expect(BuffTask.last(3).map(&:request_message_id))
            .to match_array(expected_original_message_ids)
        end

        it "calls MissingBuffsNotifier" do
          expect(MissingBuffsNotifier).to receive(:new).with(expected_missed_buffs, message_id, chat_id)
          expect(buffs_notifier).to receive(:call)

          handler.call
        end
      end

      context "when first apo have diff 2 (voices - assigned_tasks), race apo missing" do
        let(:expected_missed_buffs) { [0] }

        let(:expected_original_message_ids) do
          [original_message_id_1,
           original_message_id_1,
           original_message_id_2]
        end

        it "creates 3 new buff tasks" do
          expect { handler.call }.to change(BuffTask, :count).by(3)
          expect(BuffTask.last(3).map(&:request_message_id))
            .to match_array(expected_original_message_ids)
        end

        it "calls MissingBuffsNotifier" do
          expect(MissingBuffsNotifier).to receive(:new).with(expected_missed_buffs, message_id, chat_id)
          expect(buffs_notifier).to receive(:call)
          handler.call
        end
      end
    end
  end
end

