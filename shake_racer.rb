#!/usr/bin/env ruby

require "bundler/setup"
require "goliath"
require 'goliath/websocket'

require_relative 'lib/registry'
require_relative 'lib/team'
require_relative 'lib/member'
require_relative 'lib/match'
require_relative 'lib/router'

class ShakeRacer < Goliath::WebSocket
  use(Rack::Static,
      :root => Goliath::Application.app_path("public"),
      :urls => ['/blue.html', '/red.html', '/arena.html', '/index.html', '/css', '/themes', '/js', '/img'])

  def on_open(env)
    env.logger.info("WS OPEN")
    env['subscription_id'] = env.channel.connect(env)
  end

#  def on_headers(env, headers)
#    super
#    env.logger.info 'proxying new request: ' + headers.inspect
#    env['client-headers'] = headers
#  end

  def on_message(env, msg)
    env.logger.info("WS MESSAGE: #{msg}")
    env.registry.inject(msg, env)
  end

  def on_close(env)
    env.logger.info("WS CLOSED")
    env.channel.disconnect(env['subscription_id'])
  end

  def on_error(env, error)
    env.logger.error error
  end

  def response(env)
    env.logger.info("request path: #{env['REQUEST_PATH']}")
    case env['REQUEST_PATH']
    when '/blue'
      env['subscriptions'] = ["team.blue"]
      super(env)
    when '/red'
      env['subscriptions'] = ["team.red"]
      super(env)
    when '/arena_ws'
      env["subscriptions"] = ["arena.#"]
      super(env)
    end
  end
end
