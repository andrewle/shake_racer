class Match
  attr_accessor :team_name1, :team_name2, :score1, :score2, :seconds_left

  def initialize(team_name1, team_name2)
    @team_name1 = team_name1
    @team_name2 = team_name2
    @score1 = 0
    @score2 = 0
    @seconds_left = 0
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
end
