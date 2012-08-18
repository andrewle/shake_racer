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

  def post_init
    env.logger.info("post_init")
    super
  end

  def on_open(env)
    env.logger.info("WS OPEN")
    env['subscription'] = env.channel.subscribe { |m| env.stream_send(m) }
  end

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
    super(env) if env['REQUEST_PATH'] == '/ws'
  end
end
