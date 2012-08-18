require_relative 'application_model'

class Member < ApplicationModel
  def initialize(server, member_id)
    super(server)
    @member_id = member_id
  end
end
