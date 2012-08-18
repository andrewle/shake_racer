require 'json'

class ApplicationModel
  def initialize(server)
    @server = server
  end

  def send_message(message)
    @server.config['channel'] << JSON.generate(message)
    @server.logger.info "send: #{JSON.pretty_generate(message)}"
  end
end
