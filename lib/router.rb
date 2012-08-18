require_relative "routing_map"

class Router
  def initialize
    @subscriptions = {}
    @routing_map   = RoutingMap.new
    @uid  = 0
  end

  # Connects a client to the router, subscribing him to the routing keys
  # specified. Client should be a hash-like object that includes the following
  # options:
  #
  # @param [Hash] client A Goliath env representing the client to connect
  # @option client [Array<String>] client.subscriptions Array of routing keys
  #   to subscribe to
  # @option client [Proc] client.stream_send Proc containing handle to an open
  #   socket connection to forward messages to
  def connect(client)
    subscription_id = gen_id
    subscribe(client['subscriptions'], subscription_id, client)
    subscription_id
  end

  # Disconnects a client from the router. The client is unsubscribed from all
  # routing keys he was previously bound to.
  #
  # @param [String] subscription_id
  def disconnect(subscription_id)
    EM.schedule do
      @subscriptions.delete(subscription_id)
      @routing_map.unsubscribe(subscription_id)
    end
  end

  # Send a message out to all subscribers matching the routing key
  #
  # @param [String] message A string (usually JSON) message to send
  # @param [String] routing_key Only send messages to clients matching this
  #   routing key. If omitted, the message will be broadcasted to all clients.
  def send(message, routing_key = "")
    message = message.dup
    EM.schedule {
      subscribers = find_subscribers(routing_key)
      subscribers.each do |subscription_id|
        @subscriptions[subscription_id].call(message)
      end
    }
  end

  # Subscribes the client to another set of subscriptions
  def subscribe(subscriptions, subscription_id, client)
    conn = lambda { |m| client.stream_send(m) }

    EM.schedule do
      @subscriptions[subscription_id] = EM::Callback(&conn)
      @routing_map.subscribe(subscriptions, subscription_id)
    end

    client.logger.info "subscriptions: " + @subscriptions.inspect
    client.logger.info "routing_map: " + @routing_map.inspect
  end

  private
  def find_subscribers(routing_key)
    if routing_key.empty?
      @subscriptions.keys
    else
      @routing_map.subscribers_for(routing_key)
    end
  end

  def gen_id
    @uid += 1
  end
end
