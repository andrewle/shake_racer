require_relative 'application_model'

class Team < ApplicationModel
  attr_accessor :name, :member_count

  def initialize(server, name)
    super(server)
    @name = name
    @member_count = 0
  end

  def inc_members
    @member_count += 1
  end

  def dec_members
    @member_count -= 1 unless @member_count == 0
  end

  def to_hash
    { name: @name }
  end
end
