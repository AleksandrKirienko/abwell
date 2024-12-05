# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuffTask, type: :model do
  describe 'associations' do
    it { should belong_to(:game_account) }
    it { should belong_to(:apostol_profile) }
  end

  describe 'validations' do
    subject { build(:buff_task) }

    it { should validate_presence_of(:buff_type) }

    context 'uniqueness validation' do
      let(:game_account) { create(:game_account) }

      it 'allows only one unresolved buff task of the same type per game account' do
        # Создаем первую задачу
        create(:buff_task, game_account: game_account, buff_type: 1, resolved: false)

        # Пытаемся создать вторую задачу того же типа
        duplicate_task = build(:buff_task, game_account: game_account, buff_type: 1, resolved: false)

        expect(duplicate_task).not_to be_valid
        expect(duplicate_task.errors[:game_account_id]).to include('already has an unresolved buff task of this type')
      end

      it 'allows multiple resolved buff tasks of the same type' do
        create(:buff_task, game_account: game_account, buff_type: 1, resolved: true)
        new_task = build(:buff_task, game_account: game_account, buff_type: 1, resolved: true)

        expect(new_task).to be_valid
      end

      it 'allows buff tasks of different types for the same game account' do
        create(:buff_task, :attack, game_account: game_account, resolved: false)
        defense_task = build(:buff_task, :defense, game_account: game_account, resolved: false)

        expect(defense_task).to be_valid
      end

      it 'allows new buff task after previous one was resolved' do
        task = create(:buff_task, game_account: game_account, buff_type: 1, resolved: false)
        task.resolve

        new_task = build(:buff_task, game_account: game_account, buff_type: 1, resolved: false)
        expect(new_task).to be_valid
      end
    end
  end

  describe '#resolve' do
    let(:buff_task) { create(:buff_task) }

    it 'marks the task as resolved' do
      expect { buff_task.resolve }.to change { buff_task.resolved }.from(false).to(true)
    end

    it 'persists the resolved status' do
      buff_task.resolve
      expect(buff_task.reload.resolved).to be true
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:buff_task)).to be_valid
    end

    it 'has a valid attack trait' do
      expect(build(:buff_task, :attack)).to be_valid
      expect(build(:buff_task, :attack).buff_type).to eq(1)
    end

    it 'has a valid defense trait' do
      expect(build(:buff_task, :defense)).to be_valid
      expect(build(:buff_task, :defense).buff_type).to eq(2)
    end
  end
end
