class MessageFlagsHandler
  UNREAD = 1
  OUTBOX = 2
  REPLIED = 4
  IMPORTANT = 8
  CHAT = 16
  FRIENDS = 32
  SPAM = 64
  DELETED = 128
  FIXED = 256
  MEDIA = 512
  HIDDEN = 65536
  DELETED_FOR_ALL = 131072
  CHAT_WITH_NAMES = 524288

  def self.interpret(flags)
    result = []
    result << "Не прочитано" if (flags & UNREAD) != 0
    result << "Исходящее" if (flags & OUTBOX) != 0
    result << "С ответом" if (flags & REPLIED) != 0
    result << "Важное" if (flags & IMPORTANT) != 0
    result << "Чат" if (flags & CHAT) != 0
    result << "Друзья" if (flags & FRIENDS) != 0
    result << "Спам" if (flags & SPAM) != 0
    result << "Удалено" if (flags & DELETED) != 0
    result << "Закреплено" if (flags & FIXED) != 0
    result << "Содержит медиа" if (flags & MEDIA) != 0
    result << "Отправлено через чат для сообществ" if (flags & HIDDEN) != 0
    result << "Удалено для всех" if (flags & DELETED_FOR_ALL) != 0
    result << "Беседа с поддержкой имен" if (flags & CHAT_WITH_NAMES) != 0
    result
  end
end

# Использование:
#
# flags = 532481
# interpretations = MessageFlags.interpret(flags)
# puts "Флаг #{flags} означает:"
# interpretations.each { |interp| puts "- #{interp}" }
#
# Флаг 532481 означает:
#   - Не прочитано
# - Отправлено через чат для сообществ
# - Беседа с поддержкой имен
