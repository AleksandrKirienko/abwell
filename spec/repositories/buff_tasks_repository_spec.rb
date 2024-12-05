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
end
