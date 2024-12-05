# frozen_string_literal: true

class ApostolProfile < ApplicationRecord
  belongs_to :game_account
  has_many :buff_tasks

  validates :voice_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :buffs_given, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :races, presence: true, if: -> { races.present? }

  #
  # # Пример использования
  # def display_buff_type
  #   BuffType.t(buff_type)
  # end
end

# def chat_exists?(access_token, chat_id)
#   vk = VkontakteApi::Client.new(access_token)
#
#   begin
#     response = vk.messages.get_conversations_by_id(
#       peer_ids: chat_id,
#       extended: 0
#     )
#
#     # Если чат существует, в ответе будет хотя бы одна запись
#     !response.items.empty?
#   rescue VkontakteApi::Error => e
#     # Обработка ошибок VK API
#     Rails.logger.error "VK API Error: #{e.message}"
#     false
#   end
# end
