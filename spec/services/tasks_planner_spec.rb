# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksPlanner do
  subject(:planner) do
    described_class.new(
      message_id: message_id,
      vk_id: game_account.vk_id,
      race_buff: race_buff,
      standard_buffs: standard_buffs
    )
  end

  let(:message_id) { 123456 }
  let(:race_buff) { BuffType::HUMAN }
  let(:standard_buffs) { [7, 8, 9] }
  let!(:game_account) { create(:game_account) }
  let(:chat_id) { 111 }

  let(:enough_counts) { { voices: 3, tasks: 0 } }
  let(:not_enough_counts) { { voices: 0, tasks: 0 } }
  let(:with_tasks_counts) { { voices: 3, tasks: 3 } }
  let(:counts) { enough_counts }
  let(:voice_count) { counts[:voices] }
  let(:tasks_count) { counts[:tasks] }

  describe '#call' do
    context 'when all apostols are available' do
      let!(:human_apostol) do
        create(:apostol_profile, :with_tasks, :human,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      let!(:standard_apostol) do
        create(:apostol_profile, :with_tasks,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      it 'creates buff tasks for all buffs' do
        expect { planner.call }.to change(BuffTask, :count).by(4)
      end

      it 'returns empty missing buffs array' do
        expect(planner.call).to be_empty
      end

      it 'creates tasks with correct attributes' do
        planner.call
        tasks = BuffTask.last(4)

        expect(tasks.first).to have_attributes(
                                 game_account: game_account,
                                 apostol_profile: human_apostol,
                                 buff_type: race_buff,
                                 request_message_id: message_id
                               )

        standard_buff_types = tasks[1..].map(&:buff_type)
        expect(standard_buff_types).to match_array(standard_buffs)
      end
    end

    context 'when race apostol is missing' do
      let!(:standard_apostol) do
        create(:apostol_profile, :with_tasks,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      it 'creates buff tasks only for standard buffs' do
        expect { planner.call }.to change(BuffTask, :count).by(3)
      end

      it 'returns array with missing race buff' do
        expect(planner.call).to contain_exactly(race_buff)
      end
    end

    context 'when apostol has maximum tasks' do
      let(:counts) { with_tasks_counts }

      let!(:human_apostol) do
        create(:apostol_profile, :with_tasks, :human,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      let!(:standard_apostol) do
        create(:apostol_profile, :with_tasks,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      it 'considers them as unavailable' do
        expect { planner.call }.not_to change(BuffTask, :count)
      end

      it 'returns array with all missing buffs' do
        expect(planner.call).to match_array([race_buff] + standard_buffs)
      end
    end

    context 'when apostols have not enough voices' do
      let(:counts) { not_enough_counts }

      let!(:human_apostol) do
        create(:apostol_profile, :with_tasks, :human,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      let!(:standard_apostol) do
        create(:apostol_profile, :with_tasks,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      it 'does not create any buff tasks' do
        expect { planner.call }.not_to change(BuffTask, :count)
      end

      it 'returns array with all missing buffs' do
        expect(planner.call).to match_array([race_buff] + standard_buffs)
      end
    end

    context 'with no race buff requested' do
      let(:race_buff) { nil }

      let!(:standard_apostol) do
        create(:apostol_profile, :with_tasks,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      it 'creates only standard buff tasks' do
        expect { planner.call }.to change(BuffTask, :count).by(3)
      end

      it 'returns empty missing buffs array' do
        expect(planner.call).to be_empty
      end
    end

    context 'with empty standard buffs array' do
      let(:standard_buffs) { [] }

      let!(:human_apostol) do
        create(:apostol_profile, :with_tasks, :human,
               chat_id: chat_id,
               voice_count: voice_count,
               tasks_count: tasks_count
        )
      end

      it 'creates only race buff task' do
        expect { planner.call }.to change(BuffTask, :count).by(1)
      end

      it 'returns empty missing buffs array' do
        expect(planner.call).to be_empty
      end
    end
  end

  describe 'edge cases' do
    context 'with non-existent game account' do
      let(:planner) do
        described_class.new(
          message_id: message_id,
          vk_id: 999999,
          race_buff: race_buff,
          standard_buffs: standard_buffs
        )
      end

      it 'does not create buff tasks' do
        expect { planner.call }.not_to change(BuffTask, :count)
      end
    end
  end
end
