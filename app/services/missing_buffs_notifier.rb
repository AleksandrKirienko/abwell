# frozen_string_literal: true

class MissingBuffsNotifier
  attr_reader :missing_buffs, :message_id, :bot_chat_id

  RECOMMENDATION_PART = "Используйте команду '/апопроф' чтобы актуализировать информацию о голосах у апостолов."
  MISSING_RACE_DESCRIPTION_PART = "У апостолов запрашиваемой рассы закончились голоса, либо их вообще нет на автобафе."
  EXHAUSTED_VOICES_DESCRIPTION_PART = "У всех апостолов закончились голоса."
  NOT_PRESENTED = "не будет."
  BUFF_WORD_FORMS = { singular: "Бафа", plural: "Бафов" }

  def initialize(missing_buffs, message_id, bot_chat_id)
    @missing_buffs = missing_buffs
    @message_id = message_id
    @bot_chat_id = bot_chat_id
  end

  def call
    missing_standard_buffs = missing_buffs & BuffType.standard_buffs
    return notify_voices_exhausted(missing_standard_buffs) if missing_standard_buffs.present?

    missing_race_buffs = missing_buffs & BuffType.race_buffs
    notify_missing_race(missing_race_buffs) if missing_race_buffs.present?
  end

  private

  def notify_voices_exhausted(buff_types)
    message = [build_buff_absent_part(buff_types),
               EXHAUSTED_VOICES_DESCRIPTION_PART,
               RECOMMENDATION_PART].join("\n")

    notify(message)
  end

  def notify_missing_race(race_buff_type)
    message = [build_buff_absent_part(race_buff_type),
               MISSING_RACE_DESCRIPTION_PART,
               RECOMMENDATION_PART].join("\n")

    notify(message)
  end

  def build_buff_absent_part(buff_types)
    list_string = BuffType::STRING_TO_BUFF.invert.values_at(*buff_types).join(", ")
    pluralized_buff_word = buff_types.count > 1 ? BUFF_WORD_FORMS[:plural] : BUFF_WORD_FORMS[:singular]

    [pluralized_buff_word, list_string, NOT_PRESENTED].join(" ")
  end

  def notify(message_text)
    api_client.send_message(message_text, bot_chat_id, reply_to: message_id)
  end

  def api_client
    @api_client = Api::VkClient.new
  end
end
