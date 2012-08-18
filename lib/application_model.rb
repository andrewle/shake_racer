require 'json'

class ApplicationModel
  attr_reader :server

  def initialize(server)
    @server = server
  end

  def send_message(message, routing_key)
    @server.config['channel'].send(JSON.generate(message), routing_key)
#    @server.logger.info "send: #{JSON.pretty_generate(message)}"
  end
end
