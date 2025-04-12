# frozen_string_literal: true

class TasksPlanner
  include LoggerHelper

  attr_reader :message_text, :sender_id, :race_buff, :standard_buffs, :bot_chat_id

  def initialize(message_text:, sender_id:, bot_chat_id:, race_buff: nil, standard_buffs: [])
    @race_buff = race_buff
    @standard_buffs = standard_buffs
    @message_text = message_text
    @sender_id = sender_id
    @bot_chat_id = bot_chat_id
    @missing_buffs = []
  end

  def call
    logger.info("Tasks count Before creating: #{BuffTask.count}")
    handle_race_buff(race_buff)

    standard_buffs.each do |buff_type|
      handle_standard_buff(buff_type)
    end
    logger.info("Tasks count After creating: #{BuffTask.count}")
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

    logger.info( "Founded Apostol id: #{apo&.id}, bot_chat_id: #{bot_chat_id}")

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
    ApostolProfileRepository.new(bot_chat_id, race)
  end

  def game_account
    @game_account ||= GameAccount.find_by(vk_id: sender_id)
  end

  def create_buff_task(apostol_profile:, buff_type:)
    BuffTask.create(game_account: game_account,
                    apostol_profile: apostol_profile,
                    buff_type: buff_type,
                    request_message_id: profile_specific_message_id(apostol_profile))
  end

  # Message id is difference for every account,
  #   so received message_id via bot-account is not actual for ApiClient based on apostol-profile,
  #   we need to fetch actual message id
  #
  def profile_specific_message_id(apostol_profile)
    return @profile_specific_message_id if @last_handled_profile == apostol_profile

    @last_handled_profile = apostol_profile
    @profile_specific_message_id = find_message_by_history(apostol_profile)["id"]
  end

  def find_message_by_history(apostol_profile)
    response = api(apostol_profile.access_token).get_chat_history(apostol_profile.chat_id)
    response["items"].find do |message|
      message['from_id'] == sender_id && message['text'] == message_text
    end
  end

  def api(access_token)
    Api::VkClient.new(access_token)
  end
end
