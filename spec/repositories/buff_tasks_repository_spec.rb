# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuffTasksRepository do
  subject(:repository) { described_class.new }

  describe '#get_oldest_unresolved_tasks_for_available_apostols' do
    let!(:apostol1) { create(:apostol_profile, last_buff_given_at: 2.minutes.ago) }
    let!(:apostol2) { create(:apostol_profile, last_buff_given_at: 2.minutes.ago) }
    let!(:timeout_apostol) { create(:apostol_profile, last_buff_given_at: 30.seconds.ago) }

    let!(:old_task1) do
      create(:buff_task,
             apostol_profile: apostol1,
             created_at: 10.minutes.ago,
             resolved: false)
    end

    let!(:newer_task1) do
      create(:buff_task,
             apostol_profile: apostol1,
             created_at: 5.minutes.ago,
             resolved: false)
    end

    let!(:task2) do
      create(:buff_task,
             apostol_profile: apostol2,
             created_at: 7.minutes.ago,
             resolved: false)
    end

    let!(:resolved_task) do
      create(:buff_task,
             apostol_profile: apostol1,
             created_at: 15.minutes.ago,
             resolved: true)
    end

    let!(:timeout_task) do
      create(:buff_task,
             apostol_profile: timeout_apostol,
             created_at: 5.minutes.ago,
             resolved: false)
    end

    it 'returns oldest unresolved task for each available apostol' do
      tasks = repository.get_oldest_unresolved_tasks_for_available_apostols

      expect(tasks).to match_array([old_task1, task2])
      expect(tasks).not_to include(newer_task1, resolved_task, timeout_task)
    end

    it 'orders tasks by creation time within each apostol' do
      tasks = repository.get_oldest_unresolved_tasks_for_available_apostols.to_a

      expect(tasks.first).to eq(old_task1)
      expect(tasks.second).to eq(task2)
    end

    context 'when apostol is on timeout' do
      let!(:recent_apostol) { create(:apostol_profile, last_buff_given_at: 30.seconds.ago) }
      let!(:recent_task) do
        create(:buff_task,
               apostol_profile: recent_apostol,
               created_at: 1.minute.ago,
               resolved: false)
      end

      it 'excludes tasks for apostols on timeout' do
        tasks = repository.get_oldest_unresolved_tasks_for_available_apostols

        expect(tasks).not_to include(recent_task)
      end
    end

    context 'when all tasks are resolved' do
      before do
        BuffTask.update_all(resolved: true)
      end

      it 'returns empty collection' do
        tasks = repository.get_oldest_unresolved_tasks_for_available_apostols

        expect(tasks).to be_empty
      end
    end
  end

  describe '#get_oldest_unresolved_task_for_apostol' do
    let!(:apostol) { create(:apostol_profile) }
    let!(:old_task) { create(:buff_task, apostol_profile: apostol, created_at: 10.minutes.ago, resolved: false) }
    let!(:new_task) { create(:buff_task, apostol_profile: apostol, created_at: 5.minutes.ago, resolved: false) }
    let!(:resolved_task) { create(:buff_task, apostol_profile: apostol, created_at: 15.minutes.ago, resolved: true) }

    it 'returns the oldest unresolved task for the given apostol' do
      expect(repository.get_oldest_unresolved_task_for_apostol(apostol.id)).to eq(old_task)
    end

    context 'when there are no unresolved tasks' do
      before { BuffTask.update_all(resolved: true) }

      it 'returns nil' do
        expect(repository.get_oldest_unresolved_task_for_apostol(apostol.id)).to be_nil
      end
    end
  end

  describe '#get_all_unresolved_for_apostol' do
    let!(:apostol) { create(:apostol_profile) }
    let!(:task1) { create(:buff_task, apostol_profile: apostol, resolved: false) }
    let!(:task2) { create(:buff_task, apostol_profile: apostol, resolved: false) }
    let!(:resolved_task) { create(:buff_task, apostol_profile: apostol, resolved: true) }

    it 'returns all unresolved tasks for the given apostol' do
      expect(repository.get_all_unresolved_for_apostol(apostol.id)).to match_array([task1, task2])
    end

    it 'does not include resolved tasks' do
      expect(repository.get_all_unresolved_for_apostol(apostol.id)).not_to include(resolved_task)
    end

    context 'when there are no unresolved tasks' do
      before { BuffTask.update_all(resolved: true) }

      it 'returns an empty collection' do
        expect(repository.get_all_unresolved_for_apostol(apostol.id)).to be_empty
      end
    end
  end

  describe '#get_by_account_id_chat_id_and_buff_type' do
    let!(:game_account) { create(:game_account) }
    let!(:apostol_profile) { create(:apostol_profile, bot_chat_id: apo_bot_chat_id) }
    let!(:task) do
      create(:buff_task, game_account: game_account, apostol_profile: apostol_profile,
                         resolved: false, buff_type: 0)
    end

    let(:required_chat_id) { 111 }
    let(:apo_bot_chat_id) { required_chat_id }

    before do
      create(:buff_task, game_account: game_account, apostol_profile: apostol_profile,
             resolved: true, buff_type: 0)
    end

    it 'returns the unresolved task for the given game_account_id, chat_id and buff_type with associated profiles' do
      result = repository.get_by_account_id_chat_id_and_buff_type(game_account.id,
                                                                  required_chat_id,
                                                                  BuffType::HUMAN)

      expect(result).to eq(task)
      expect(result.apostol_profile).to eq(apostol_profile)
      expect(result.game_account).to eq(game_account)
    end

    context 'when no unresolved task exists for the given game_account_id and buff_type' do
      before { BuffTask.update_all(resolved: true) }

      it 'returns nil' do
        result = repository.get_by_account_id_chat_id_and_buff_type(game_account.id,
                                                                    required_chat_id,
                                                                    BuffType::HUMAN)

        expect(result).to be_nil
      end
    end

    context "when task with another chat id" do
      let(:apo_bot_chat_id) { 222 }

      it 'returns nil' do
        result = repository.get_by_account_id_chat_id_and_buff_type(game_account.id,
                                                                    required_chat_id,
                                                                    BuffType::HUMAN)

        expect(result).to be_nil
      end
    end
  end

  describe '#get_unresolved_by_apostol_profile_id_and_races' do
    let!(:apostol_profile) { create(:apostol_profile) }
    let!(:task1) { create(:buff_task, apostol_profile: apostol_profile, buff_type: 1, resolved: false) }
    let!(:task2) { create(:buff_task, apostol_profile: apostol_profile, buff_type: 2, resolved: false) }
    let!(:task3) { create(:buff_task, apostol_profile: apostol_profile, buff_type: 3, resolved: false) }
    let!(:resolved_task) { create(:buff_task, apostol_profile: apostol_profile, buff_type: 1, resolved: true) }

    it 'returns unresolved tasks matching the given races' do
      tasks = repository.get_unresolved_by_apostol_profile_id_and_races(apostol_profile.id, [1, 2])

      expect(tasks).to match_array([task1, task2])
    end

    it 'does not include tasks with different races' do
      tasks = repository.get_unresolved_by_apostol_profile_id_and_races(apostol_profile.id, [1, 2])

      expect(tasks).not_to include(task3)
    end

    it 'does not include resolved tasks' do
      tasks = repository.get_unresolved_by_apostol_profile_id_and_races(apostol_profile.id, [1])

      expect(tasks).not_to include(resolved_task)
    end

    context 'when there are no matching tasks' do
      it 'returns an empty collection' do
        tasks = repository.get_unresolved_by_apostol_profile_id_and_races(apostol_profile.id, [4])

        expect(tasks).to be_empty
      end
    end
  end
end
