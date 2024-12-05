# frozen_string_literal: true

class BuffResultMessageParser
  REGULAR_FOR_ID = /id(\d+)/
  REGULAR_BUFF_TYPE = /благословение\s+(.*?)(\.|!|\s*Вы)/i
  REGULAR_APOSTOL_VOICE = /Голос у Апостола:\s*(\d+)/

  attr_reader :message_text

  def initialize(message_text)
    @message_text = message_text
  end

  def extract_id
    message_text.match(REGULAR_FOR_ID)[1].to_i
  end

  def extract_buff_type
    buff_type = message_text.match(REGULAR_BUFF_TYPE)[1]

    BuffType.string_to_types(buff_type)
  end

  def extract_voice_count
    message_text.match(REGULAR_APOSTOL_VOICE)[1].to_i
  end
end
