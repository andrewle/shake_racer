require_relative 'application_model'

class Registry < ApplicationModel
  attr_accessor :matches, :teams

  INTER_MATCH_DELAY = 3.0

  def initialize(server)
    super(server)
    @matches = [] # ordered
    @teams = []
  end

  def start_next_match
    if match = matches.shift
      match.start! do
        EM.add_timer(INTER_MATCH_DELAY) do
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
