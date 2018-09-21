require 'rails_helper'

RSpec.describe Relationship, type: :model do

  before do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    @relationship = Relationship.new(follower_id:user1.id,followed_id: user2.id)
  end

  it "is valid" do
    expect(@relationship).to be_valid
  end

  it "require a follower_id" do
    @relationship.follower_id = nil
    expect(@relationship).to_not be_valid
  end

  it "require a followed_id" do
    @relationship.followed_id = nil
    expect(@relationship).to_not be_valid
  end



end
