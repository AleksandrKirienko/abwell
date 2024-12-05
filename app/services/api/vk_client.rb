class Api::VkClient
  MESSAGE_SEARCH_PERIOD = 1.day
  MESSAGE_SEARCH_RANGE = 10
  MESSAGE_SEARCH_CHAT = -183040898

  def get_long_pool_data(ts)
    long_pool_request(ts).body
  end

  def long_pool_request(ts)
    uri = long_pool_uri(ts)
    http = Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = true
    end

    http.request(Net::HTTP::Get.new(uri.request_uri))
  rescue StandardError => e
    puts "[ERROR] #{e}"
  end

  def search_messages(message_query)
    api.messages_search(
      q: message_query,
      peer_id: MESSAGE_SEARCH_CHAT,
      timestamp_from: MESSAGE_SEARCH_PERIOD.ago.to_i,
      timestamp_to: Time.current.to_i,
      count: MESSAGE_SEARCH_RANGE,
    )
  end

  def send_message(message)
    api.messages_send(
      chat_id: MESSAGE_SEARCH_CHAT,
      random_id: rand(10000..99999),
      message: message,
      )
  end

  private

  def long_pool_uri(ts = nil)
    key = long_pool_server['key']
    server = long_pool_server['server']
    ts ||= long_pool_server['ts']

    url = "https://#{server}?act=a_check&key=#{key}&ts=#{ts}&wait=25&mode=10&version=1"

    URI.parse(url)
  end

  def long_pool_server
    @long_pool_server ||= api.messages_getLongPollServer
  end


  def api
    Vkontakte::API.new(MY_TOKEN)
  end
end
