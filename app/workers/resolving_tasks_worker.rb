# frozen_string_literal: true

require 'sidekiq-scheduler'

class ResolvingTasksWorker
  include Sidekiq::Job

  def perform
    TasksResolver.new.call
  end
end
