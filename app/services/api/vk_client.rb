class Api::VkClient
  attr_reader :api_token

  BOT_TEST_CHAT_ID = 2
  DEFAULT_HISTORY_SIZE = 50

  def initialize(api_token = bot_api_token)
    @api_token = api_token
  end

  def get_long_pool_data(ts: nil)
    long_pool_request(ts)&.body
  end

  def get_chat_history(chat_id = BOT_TEST_CHAT_ID, count: DEFAULT_HISTORY_SIZE)
    api.messages_getHistory(
      peer_id: normalize_chat_id(chat_id, full: true),
      count: count
    )
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

  def search_messages(message_query, peer_id, period, count)
    api.messages_search(
      q: message_query,
      peer_id: peer_id,
      timestamp_from: period.ago.to_i,
      timestamp_to: Time.current.to_i,
      count: count,
    )
  end

  def send_message(message, chat_id, reply_to: nil)
    params = { chat_id: normalize_chat_id(chat_id),
               random_id: rand(10000..99999),
               message: message }
    params.merge!(reply_to: reply_to) if reply_to

    api.messages_send(**params)
  end

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
    Vkontakte::API.new(api_token).tap do |api|
      raise VkApiInitializeError unless api
    end
  end

  def bot_api_token
    ENV["BOT_ACCESS_TOKEN"]
  end

  def normalize_chat_id(chat_id, full: false)
    normalized_chat_id = chat_id.to_i.then { |id| id > 2000000000 ? id - 2000000000 : id }

    full ? normalized_chat_id + 2000000000 : normalized_chat_id
  end

  class VkApiInitializeError < StandardError; end
end
