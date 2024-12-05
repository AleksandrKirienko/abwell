# frozen_string_literal: true

class HandleChatWorker
  include Sidekiq::Worker

  def perform
    call
  rescue StandardError => e
    # Добавьте логирование ошибок
    logger.error "HandleChatWorker error: #{e.message}"
    logger.error e.backtrace.join("\n")
    raise # Перебросить ошибку, чтобы Sidekiq мог её отследить
  end

  def call
    long_pool_data = api_client.get_long_pool_data(get_ts)
    parsed_data = parse(long_pool_data)

    set_ts(parsed_data["ts"])

    parsed_data["updates"].each do |event|
      EventHandler.new(event).call
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

