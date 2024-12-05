# frozen_string_literal: true
class LongPoolApi
  MY_TOKEN = "vk1.a.LPTW3yA9Cy7-u6HL2p0DiA3wQxYzZ-kfoLceroSHMxqVwfONWohjGEs6ZTNptV4kjJh-GhyuyL46Ee-7I7rV55veSnQOWbcGMQT-yZTP1Rx5VUe6QPt1hhsDNPwR_4lZObGNtJFS7hye3fQq1N0dPw2MoVsJSEJ3MbVt23QgF5aljfA3v94ZP5efOLcxf64OSbHFbuQvqZoCvfgVF1IzAw"
  GUILD_CHAT_ID = "102"
  OFFLINE = "\033[31;3mофлайн\033[0m"
  ONLINE = "\033[32;3mонлайн\033[0m"

  def get_updates
    uri = long_pool_uri
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.request(Net::HTTP::Get.new(uri.request_uri))
  rescue StandardError => e
    puts "[ERROR] #{e}"
  end
  # JSON.parse(res.body)

  def run_long_pool(wait_time: 5)
    ts = nil

    loop do
      uri = long_pool_uri(ts)
      http = Net::HTTP.new(uri.host, uri.port).tap { |http| http.use_ssl = true }

      begin
        res = http.request(Net::HTTP::Get.new(uri.request_uri))
      rescue StandardError => e
        puts "[ERROR] #{e}"
        sleep wait_time
        retry
      end

      begin
        params = JSON.parse(res.body)
      rescue JSON::ParserError
        puts '[ERROR] JSON Parse Error'
      end

      params['updates']&.each do |param|
        p param
      end

      ts = params['ts']
    end
  end


  def long_pool_server
    @long_pool_server ||= api.messages_getLongPollServer
  end

  def long_pool_uri(ts = nil)
    key = long_pool_server['key']
    server = long_pool_server['server']
    ts ||= long_pool_server['ts']

    url = "https://#{server}?act=a_check&key=#{key}&ts=#{ts}&wait=25&mode=10&version=1"

    URI.parse(url)
  end

  def api
    Vkontakte::API.new(MY_TOKEN)
  end
end
