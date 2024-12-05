# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuffRequestMessageHandler do
  subject(:handler) { described_class.new(request_string, message_id, game_account.vk_id, chat_id) }

  let(:message_id) { 3442839 }
  let(:chat_id) { 102 }
  let(:request_string) { "/чазу" }

  let(:enough_counts) { { voices: 4, tasks: 2 } }
  let(:not_enough_counts) { { voices: 3, tasks: 2 } }
  let(:counts) { enough_counts }
  let(:voice_count) { counts[:voices] }
  let(:tasks_count) { counts[:tasks] }

  let!(:game_account) { create :game_account }

  let!(:not_hum_apo2) do
    create(:apostol_profile, :with_tasks, :not_human, chat_id: chat_id,
           voice_count: voice_count, tasks_count: tasks_count)
  end

  let!(:not_hum_apo3) do
    create(:apostol_profile, :with_tasks, :not_human, chat_id: chat_id,
           voice_count: voice_count, tasks_count: tasks_count)
  end


  # with missing buffs: create 3 apos with 3 voices and 2 tasks each OR no one human
  # without missing buffs: create 3 apos with 4 voices and 2 tasks each human presented

  describe "#call" do
    context "when missing buffs are present" do
      context "when race apo presented but not enough voices" do
        let!(:hum_apo1) do
          create(:apostol_profile, :with_tasks, :human, chat_id: chat_id,
                 voice_count: voice_count, tasks_count: tasks_count)
        end

        let(:counts) { not_enough_counts }
        let(:expected_missed_buffs) { [9] }

        it "creates 3 new buff tasks" do
          expect { handler.call }.to change(BuffTask, :count).by(3)
        end

        it "calls MissingBuffsNotifier" do
          allow(MissingBuffsNotifier).to receive(:new).and_call_original
          expect(MissingBuffsNotifier).to receive(:new).with(expected_missed_buffs, message_id, chat_id)

          handler.call
        end
      end

      context "when race apo missing" do
        let!(:not_hum_apo1) do
          create(:apostol_profile, :with_tasks, :not_human, chat_id: chat_id,
                 voice_count: voice_count, tasks_count: tasks_count)
        end
        let(:expected_missed_buffs) { [0] }

        it "creates 3 new buff tasks" do
          expect { handler.call }.to change(BuffTask, :count).by(3)
        end

        it "calls MissingBuffsNotifier" do
          allow(MissingBuffsNotifier).to receive(:new).and_call_original
          expect(MissingBuffsNotifier).to receive(:new).with(expected_missed_buffs, message_id, chat_id)
          handler.call
        end
      end
    end
  end
end
