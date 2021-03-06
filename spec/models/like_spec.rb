# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  likeable_id   :integer
#  likeable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe Like, :type => :model do

  context "model" do
    it { is_expected.to respond_to(:likeable_id) }
    it { is_expected.to respond_to(:likeable_type) }
  end

  context "user" do
    describe "" do
      pending("should this be polymorphic at all? what about a join table?")
    end

    describe "action on delete of parent" do
      pending('deletes like? or keeps some kind of record of former-like?')
    end
  end

end
