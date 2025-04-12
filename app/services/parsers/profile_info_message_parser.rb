# frozen_string_literal: true

class Parsers::ProfileInfoMessageParser
  REGULAR_FOR_ID = /id(\d+)/
  REGULAR_APOSTOL_VOICE = /апостол\s*\((\d+)\)/

  attr_reader :message_text

  def initialize(message_text)
    @message_text = message_text
  end

  def extract_id
    message_text.match(REGULAR_FOR_ID)[1].to_i
  end

  def extract_voice_count
    message_text.match(REGULAR_APOSTOL_VOICE)[1].to_i
  end
end
