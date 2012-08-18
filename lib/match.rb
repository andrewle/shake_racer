class Match
  attr_accessor :team_name1, :team_name2, :score1, :score2, :seconds_left

  HZ = 25
  PERIOD = 1.0/HZ
  MATCH_SECONDS = 10.0
  COUNTDOWN_SECONDS = 3

  def initialize(server, team_name1, team_name2)
    @server = server
    @team_name1 = team_name1
    @team_name2 = team_name2
    @score1 = 0
    @score2 = 0
    @seconds_left = 0.0
  end

  def match_name
    "#{team_name1} vs. #{team_name2}"
  end

  def countdown(count = COUNTDOWN_SECONDS, &block)
    @server.logger.info "#{count}!"
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

  def run!
    @seconds_left = MATCH_SECONDS
    timer = EM.add_periodic_timer(PERIOD) do
      scores = { :racers => [{:name => @team_name1, :score => @score1},
                             {:name => @team_name2, :score => @score2}] }
      @server.config['channel'] << JSON.generate(scores)
      @seconds_left -= PERIOD
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
