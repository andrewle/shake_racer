require_relative 'application_model'

class Team < ApplicationModel
  attr_accessor :name, :members

  def initialize(server, name)
    super(server)
    @name = name
    @members = []
  end

  def find_member(member_id)
    @members.find { |member| member.member_id == member_id }
  end

  def to_hash
    { name: @name }
  end
end
