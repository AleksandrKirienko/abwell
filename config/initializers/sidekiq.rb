require 'sidekiq'
require 'sidekiq-scheduler'
require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  config.on(:startup) do
    TsRepository.new.del_ts

    Sidekiq.schedule = YAML.load_file(File.expand_path('../../sidekiq.yml', __FILE__))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
