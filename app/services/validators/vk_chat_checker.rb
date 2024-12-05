# class VkChatChecker
#   def initialize(access_token)
#     @vk = VkontakteApi::Client.new(access_token)
#   end
#
#   def check_chat(chat_id)
#     peer_id = format_peer_id(chat_id)
#
#     begin
#       response = @vk.messages.get_conversations_by_id(
#         peer_ids: peer_id,
#         extended: 0
#       )
#
#       {
#         exists: !response.items.empty?,
#         error: nil
#       }
#     rescue VkontakteApi::Error => e
#       {
#         exists: false,
#         error: e.message
#       }
#     end
#   end
#
#   private
#
#   def format_peer_id(chat_id)
#     # Если это ID группового чата, добавляем префикс
#     if chat_id.to_s.length <= 7  # Предполагаем, что это локальный ID чата
#       2000000000 + chat_id.to_i
#     else
#       chat_id
#     end
#   end
# end
#
# # Использование:
# checker = VkChatChecker.new('your_access_token')
# result = checker.check_chat(123456)
#
# if result[:error]
#   puts "Ошибка при проверке чата: #{result[:error]}"
# else
#   puts "Чат #{result[:exists] ? 'существует' : 'не существует'}"
# end
# # app/services/vk_chat_service.rb
# class VkChatService
#   def initialize(access_token)
#     @vk = VkontakteApi::Client.new(access_token)
#   end
#
#   def chat_exists?(chat_id)
#     peer_id = format_peer_id(chat_id)
#
#     begin
#       response = @vk.messages.get_conversations_by_id(
#         peer_ids: peer_id,
#         extended: 0
#       )
#       !response.items.empty?
#     rescue VkontakteApi::Error => e
#       Rails.logger.error "VK API Error checking chat #{chat_id}: #{e.message}"
#       false
#     end
#   end
#
#   private
#
#   def format_peer_id(chat_id)
#     chat_id.to_s.length <= 7 ? 2000000000 + chat_id.to_i : chat_id
#   end
# end
# class ApostolProfile < ApplicationRecord
#   def verify_chat
#     service = VkChatService.new(ENV['VK_ACCESS_TOKEN'])
#     if service.chat_exists?(chat_id)
#       update(chat_verified: true)
#     else
#       update(chat_verified: false)
#     end
#   end
# end
