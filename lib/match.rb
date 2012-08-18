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

  def send_countdown(count)
    message =
    {
      :event => "Countdown",
      :count => count
    }
    send_message(message)
  end

  def send_score
    message =
    {
      :event  => 'UpdateScores',
      :racers => [{:name => @team_names[0], :score => @scores[0]},
                  {:name => @team_names[1], :score => @scores[1]}]
    }
    send_message(message)
  end

  def send_new_match
    message =
    {
      :event  => 'NewMatch'
    }
    send_message(message)
  end

  def countdown(count = COUNTDOWN_SECONDS, &block)
    send_countdown(count)
    EM.add_timer(1) do
      if count > 1
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

  def update_score
    increment = rand(4)
    player = rand < 0.5 ? 0 : 1
    @scores[player] = [@scores[player] + increment, 100].min
  end

  def run!
    @seconds_left = MATCH_SECONDS
    timer = EM.add_periodic_timer(PERIOD_SECONDS) do
      update_score
      send_score
      @seconds_left -= PERIOD_SECONDS
      @seconds_left = 0 if @scores.max >= 100
      if @seconds_left <= 0.0
        @seconds_left = 0.0
        timer.cancel
        @server.logger.info("#{match_name} match over!")
        yield # done!
      end
    end
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
