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

  def send_success(event, env)
    message = {
      :event => event + "_success"
    }
    env.stream_send(JSON.generate(message))
  end

  def send_error(event, error_message, env)
    message = {
      :event => event + "_error",
      :message => error_message
    }
    env.stream_send(JSON.generate(message))
  end
end
