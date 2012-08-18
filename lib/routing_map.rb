class RoutingMap
  def initialize
    @hash = {}
  end

  # Returns the unique set of subscriber ids who are subscribed to the given
  # routing key.
  #
  # @param [String] routing_key The routing key to find subscribers for. If
  #   routing_key is a blank string, then all subscribers are returned.
  #   Example: team.monkey
  def subscribers_for(routing_key)
    subscribers = Set.new

    @hash.each do |routing_index, subs|
      if routing_key =~ routing_index
        subscribers.merge(subs)
      end
    end

    subscribers
  end

  # Subscribes a client's subscription_id to a set of routing keys
  #
  # @param [Array<String>] routing_keys List of RabbitMQ compatible routing
  #   keys to bind to
  # @param [String] subscription_id A unique index for the identifying the
  #   client
  def subscribe(routing_keys, subscription_id)
    Array(routing_keys).each do |routing_key|
      index = routing_index(routing_key)
      @hash[index] = Set.new if @hash[index].nil?
      @hash[index] << subscription_id
    end
  end

  # Unsubscribes a client from all routing keys he is bound to.
  def unsubscribe(subscription_id)
    @hash.keys.each do |routing_index|
      next if @hash[routing_index].nil?
      @hash[routing_index].delete(subscription_id)
      @hash.delete(routing_index) if @hash[routing_index].empty?
    end
  end

  private
  # Converts a RabbitMQ compaitible hash to a Regexp that we can use to match
  # subscriptions on.
  def routing_index(routing_key)
    parsed = routing_key.sub(/^/, '^').sub(/$/, '$'). # Add anchors
    gsub(/\./, '\.').      # Make all dots inert
    gsub(/\*/, '<star>').  # Place holders for star tokens
    gsub(/#/,  '<hash>').  # Place holders for hash tokens
    gsub(/<star>/, '.+?'). # Compile stars down to non-greedy matchers
    gsub(/<hash>/, '.*')   # Compile hashes down to greedy matchers
    Regexp.compile(parsed)
  end
end
