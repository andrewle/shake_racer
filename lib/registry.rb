require_relative 'application_model'

class Registry < ApplicationModel
  attr_accessor :matches, :teams

  INTER_MATCH_SECONDS = 3.0

  def initialize(server)
    super(server)
    @matches = [] # ordered
    @teams = []
  end

  def inject(message, env)
    message_hash = JSON.parse(message)
    dispatch(message_hash, env)
  end

  def dispatch(message_hash, env)
    dispatch_method = "dispatch_#{message_hash['event']}"
    respond_to?(dispatch_method) or raise ArgumentError, "Unknown event #{message_hash.inspect}"
    send(dispatch_method, message_hash, env)
  end

  def dispatch_register(message_hash, env)
    team_name = message_hash['team'] or raise ArgumentError, "Missing team in #{message_hash.inspect}"
    if team = teams.find { |team| team.name == team_name }
      if team.members.size >= 2
        send_error('register', "Only 2 team members allowed", env)
        return
      end
    else
      team = Team.new(server, team_name)
      teams << team
    end
    team.members << Member.new(server, nil) # TODO: connection_id -Colin
    env['team_name'] = team_name
    env.channel.subscribe("team.#{team_name}", env['subscription_id'], env)
    send_success("register", env)
    send_update
  end

  def dispatch_challenge(message_hash, env)
    from_team = message_hash['from_team'] or raise ArgumentError, "Missing from_team in #{message_hash.inspect}"
    to_team   = message_hash['to_team'  ] or raise ArgumentError, "Missing to_team in #{message_hash.inspect}"
    send_message(message_hash, "team.#{to_team}") # forward to all
    send_update
  end

  def dispatch_accept(message_hash, env)
    from_team = message_hash['from_team'] or raise ArgumentError, "Missing from_team in #{message_hash.inspect}"
    to_team   = message_hash['to_team'  ] or raise ArgumentError, "Missing to_team in #{message_hash.inspect}"
    matches << Match.new(server, from_team, to_team)
    send_message(message_hash, "team.#{from_team}")
    send_update
  end

  def dispatch_shake(message_hash, env)
    acceleration = message_hash['acceleration'] or raise ArgumentError, "Missing acceleration in #{message_hash.inspect}"
    match = matches.first or raise ArgumentError, "Got Shake with no matches #{message_hash.inspect}"
    match.shake(env['team_name'])
  end

  def start_next_match
    if match = matches.first
      send_update
      match.start! do
        matches.shift
        EM.add_timer(INTER_MATCH_SECONDS) do
          start_next_match
        end unless matches.empty?
      end
    end
  end

  def find_team_for_member(member_id)
    @teams.find do |team|
      team.find_member(member_id)
    end
  end

  # Message senders

  def send_update
    message =
    {
      event:    'update',
      registry: to_hash
    }
    send_message(message, '')
  end

  def to_hash
    {
      matches:  @matches.map(&:to_hash),
      teams:    @teams  .map(&:to_hash)
    }
  end

  def to_json
    JSON.pretty_generate(to_hash)
  end
end
