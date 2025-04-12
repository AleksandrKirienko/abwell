# frozen_string_literal: true

module LoggerHelper
  def logger
    @logger ||= Sidekiq.logger
  end
end
