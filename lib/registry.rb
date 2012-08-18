require 'json'

class Registry
  attr_accessor :matches, :teams

  def initialize
    @matches = [] # ordered
    @teams = []
  end

  def find_team_for_member(member_id)
    @teams.find do |team|
      team.find_member(member_id)
    end
  end

  def to_hash
    {
      matches:  @matches.map(&:to_hash),
      teams:    @teams.map(&:to_hash)
    }
  end

  def to_json
    JSON.pretty_generate(to_hash)
  end
end
