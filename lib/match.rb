require_relative 'application_model'

class Match < ApplicationModel
  attr_accessor :team_name1, :team_name2, :score1, :score2, :seconds_left

  HZ = 25
  PERIOD = 1.0/HZ
  MATCH_SECONDS = 10.0
  COUNTDOWN_SECONDS = 3

  def initialize(server, team_name1, team_name2)
    super(server)
    @team_name1 = team_name1
    @team_name2 = team_name2
    @score1 = 0
    @score2 = 0
    @seconds_left = 0.0
  end

  def match_name
    "#{team_name1} vs. #{team_name2}"
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
      :racers => [{:name => @team_name1, :score => @score1},
                  {:name => @team_name2, :score => @score2}]
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
    countdown do
      run!(&block)
    end
  end

  def update_score
    increment = rand(4)
    if rand < 0.5
      @score1 += [increment, 100].min
    else
      @score2 += [increment, 100].min
    end
  end

  def run!
    @seconds_left = MATCH_SECONDS
    timer = EM.add_periodic_timer(PERIOD) do
      update_score
      send_score
      @seconds_left -= PERIOD
      @seconds_left = 0 if [@score1, @score2].max >= 100
      if @seconds_left <= 0.0
        @seconds_left = 0.0
        timer.cancel
        puts("#{match_name} match over!")
        yield # done!
      end
    end
  end

  def to_hash
    {
      team_name1: @team_name1,
      team_name2: @team_name2,
      score1:     @score1,
      score2:     @score2,
      seconds_left: @seconds_left
    }
  end

  def to_json
    JSON.pretty_generate(to_hash)
  end
end
