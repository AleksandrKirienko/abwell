# frozen_string_literal: true

class TsRepository
  def set_ts(timestamp)
    redis.set("ts", timestamp)
  end

  def get_ts
    redis.get("ts")
  end

  def del_ts
    redis.del("ts")
  end

  def redis
    @redis ||= Redis.new(host: "redis", port: 6379)
  end
end
