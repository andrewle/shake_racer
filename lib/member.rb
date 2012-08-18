require_relative 'application_model'

class Member < ApplicationModel
  def initialize(member_id)
    super(nil)
    @member_id = member_id
  end
end
