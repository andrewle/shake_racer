#!/usr/bin/env ruby

require "bundler/setup"
require "goliath"
require 'goliath/websocket'

require_relative 'lib/registry'
require_relative 'lib/team'
require_relative 'lib/member'
require_relative 'lib/match'

class ShakeRacer < Goliath::WebSocket
  use(Rack::Static,
      :root => Goliath::Application.app_path("public"),
      :urls => ['/arena.html', '/index.html', '/css', '/themes', '/js', '/img'])

  def on_open(env)
    env.logger.info("WS OPEN")
    env['subscription'] = env.channel.subscribe { |m| env.stream_send(m) }
  end

#  def on_headers(env, headers)
#    super
#    env.logger.info 'proxying new request: ' + headers.inspect
#    env['client-headers'] = headers
#  end

  def on_message(env, msg)
    env.logger.info("WS MESSAGE: #{msg}")
    env.channel << msg
  end

  def on_close(env)
    env.logger.info("WS CLOSED")
    env.channel.unsubscribe(env['subscription'])
  end

  def on_error(env, error)
    env.logger.error error
  end

  def response(env)
    env.logger.info("ua: #{env['client-headers']['User-Agent']}")
    env.logger.info("request path: #{env['REQUEST_PATH']}")
    case env['REQUEST_PATH']
    when '/ws'
      super(env)
    when '/arena_ws'
      env['client.tag'] = 'arena'
      super(env)
    end
  end
end
