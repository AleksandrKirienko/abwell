# frozen_string_literal: true

class TasksPlanner
  attr_reader :message_id, :vk_id, :race_buff, :standard_buffs

  def initialize(message_id:, vk_id:, race_buff: nil, standard_buffs: [])
    @race_buff = race_buff
    @standard_buffs = standard_buffs
    @message_id = message_id
    @vk_id = vk_id
    @missing_buffs = []
  end

  def call
    handle_race_buff(race_buff)

    standard_buffs.each do |buff_type|
      handle_standard_buff(buff_type)
    end

    @missing_buffs
  end

  private

  def handle_race_buff(race_buff)
    return unless race_buff

    apo_by_race = race_apo(race_buff)

    return @missing_buffs << race_buff unless apo_by_race

    create_buff_task(apostol_profile: apo_by_race, buff_type: race_buff)
  end

  def handle_standard_buff(buff_type)
    apo = standard_apo

    return @missing_buffs << buff_type unless apo

    create_buff_task(apostol_profile: apo, buff_type: buff_type)
  end

  def race_apo(race)
    apostol_profile_repository(race).get_appropriate
  end

  def standard_apo
    apostol_profile_repository.get_appropriate
  end

  def apostol_profile_repository(race = nil)
    ApostolProfileRepository.new(race)
  end

  def game_account
    @game_account ||= GameAccount.find_by(vk_id: vk_id)
  end

  def create_buff_task(apostol_profile:, buff_type:)
    BuffTask.create(game_account: game_account,
                    apostol_profile: apostol_profile,
                    buff_type: buff_type,
                    request_message_id: message_id)
  end
end
