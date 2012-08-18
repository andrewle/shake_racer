class Match
  attr_accessor :team_name1, :team_name2, :score1, :score2, :seconds_left

  HZ = 25
  PERIOD = 1.0/HZ
  MATCH_SECONDS = 30.0

  def initialize(logger, team_name1, team_name2)
    @logger = logger
    @team_name1 = team_name1
    @team_name2 = team_name2
    @score1 = 0
    @score2 = 0
    @seconds_left = 0.0
  end

  def start!
    @seconds_left = MATCH_SECONDS
    timer = EM.add_periodic_timer(PERIOD) do
      puts("timer!")
      @seconds_left -= PERIOD
      if @seconds_left <= 0.0
        @seconds_left = 0.0
        timer.cancel
        puts("match over!")
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
