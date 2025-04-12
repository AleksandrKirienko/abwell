# frozen_string_literal: true

require 'sidekiq-scheduler'

class HandlingChatWorker
  include Sidekiq::Job

  def perform
    logger.info "HandlingChatWorker started at #{Time.now}"
    call
  rescue StandardError => e
    logger.error "HandlingChatWorker error: #{e.message}"
    logger.error e.backtrace.join("\n")
    raise
  end

  def call
    long_pool_data = api_client.get_long_pool_data(ts: get_ts)
    parsed_data = parse(long_pool_data)

    set_ts(parsed_data["ts"])

    parsed_data["updates"]&.each do |event|
      EventHandler::All.new(event).call
    end
  end

  def parse(data)
    JSON.parse(data)
  rescue JSON::ParserError
    puts '[ERROR] JSON Parse Error'
  end

  def set_ts(ts)
    ts_repository.set_ts(ts)
  end

  def get_ts
    ts_repository.get_ts
  end

  def ts_repository
    @ts_repository ||= TsRepository.new
  end

  def api_client
    @api_client ||= Api::VkClient.new
  end
end
