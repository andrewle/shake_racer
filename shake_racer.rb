#!/usr/bin/env ruby

require "bundler/setup"
require "goliath"
require 'goliath/websocket'

require_relative 'lib/registry'
require_relative 'lib/team'
require_relative 'lib/match'
require_relative 'lib/router'

class ShakeRacer < Goliath::WebSocket
  use(Rack::Static,
      :root => Goliath::Application.app_path("public"),
      :urls => ['/blue.html', '/red.html', '/arena.html', '/index.html', '/css', '/themes', '/js', '/img'])

  def on_open(env)
    env.logger.info("WS OPEN")
    env['subscription_id'] = env.channel.connect(env)

    if env.teams[:blue] >= 1 && env.teams[:red] >= 1
      env.registry.matches << Match.new(env, "blue", "red")
      env.registry.start_next_match
    end
  end

  def on_message(env, msg)
    env.logger.info("WS MESSAGE: #{msg}")
    env.registry.inject(msg, env)
  end

  def on_close(env)
    env.logger.info("WS CLOSED")
    env.channel.disconnect(env['subscription_id'])
    if env['subscriptions'] == "team.blue"
      env.teams[:blue] -= 1
    elsif env['subscriptions'] == "team.red"
      env.teams[:red] -= 1
    end
  end

  def on_error(env, error)
    env.logger.error error
  end

  def response(env)
    env.logger.info("request path: #{env['REQUEST_PATH']}")
    case env['REQUEST_PATH']
    when '/blue'
      env['subscriptions'] = "team.blue"
      env.teams[:blue] += 1
      super(env)
    when '/red'
      env['subscriptions'] = "team.red"
      env.teams[:red] += 1
      super(env)
    when '/arena_ws'
      env["subscriptions"] = "arena.#"
      super(env)
    end
  end
end
