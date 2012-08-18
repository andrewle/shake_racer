require_relative 'application_model'

class Match < ApplicationModel
  attr_accessor :teams, :scores, :seconds_left

  HZ = 25
  PERIOD_SECONDS = 1.0/HZ
  MATCH_SECONDS = 10.0
  COUNTDOWN_SECONDS = 3

  def initialize(server, team_name1, team_name2)
    super(server)
    @team_names = [team_name1, team_name2]
    @scores     = [0, 0]
  end

  def match_name
    @team_names * ' vs. '
  end

  def countdown(count = COUNTDOWN_SECONDS, &block)
    send_countdown(count)
    EM.add_timer(1) do
      if count > 0
        countdown(count - 1, &block)
      else
        yield
      end
    end
  end

  def start!(&block)
    send_new_match
    countdown do
      run!(&block)
    end
  end

  def check_if_game_over
    @seconds_left = 0 if @scores.max >= 100
    if @seconds_left <= 0.0
      @seconds_left = 0.0
      if @timer
        @timer.cancel
        @timer = nil
      end
      @server.logger.info("#{match_name} match over!")
      yield # done!
    end
  end

  def run!(&block)
    @seconds_left = MATCH_SECONDS
    @timer = EM.add_periodic_timer(PERIOD_SECONDS) do
      @seconds_left -= PERIOD_SECONDS
      check_if_game_over(&block)
    end
  end

  def shake(team_name)
    team_names.each_with_index { |team, index| team_index = index if team == team_name }
    team_index or raise ArgumentError "Team #{team_name} not found in #{to_hash.inspect}"
    increment = rand(4)
    @scores[team_index] = [@scores[team_index] + increment, 100].min
    send_score
  end

  private
  # Message senders

  def send_countdown(count)
    message =
    {
      :event => "Countdown",
      :count => count
    }
    send_message(message, '')
  end

  def send_score
    message =
    {
      :event  => 'UpdateScores',
      :racers => [{:name => @team_names[0], :score => @scores[0]},
                  {:name => @team_names[1], :score => @scores[1]}]
    }
    send_message(message, 'arena.update_score')
  end

  def send_new_match
    message =
    {
      :event  => 'NewMatch',
      :match  => to_hash
    }
    send_message(message, '')
  end

  def to_hash
    {
      team_names:   @team_names,
      scores:       @scores,
      seconds_left: @seconds_left
    }
  end

  def to_json
    JSON.pretty_generate(to_hash)
  end
end
