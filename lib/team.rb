class Team
  attr_accessor :name

  def initialize(name)
    @name = name
    @members = []
  end

  def name=(value)
    @name = value.strip.downcase
  end

  def find_member(member_id)
    @members.find { |member| member.member_id == member_id }
  end

  def to_hash
    { name: @name }
  end
end
