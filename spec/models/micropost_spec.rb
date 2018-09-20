require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user){ FactoryBot.build(:user) }
  let(:micropost){ FactoryBot.build(:micropost) }

  it "user has many microposts" do

    u = User.new(name:"n",email:"test@test.co.jp",password:"foobar")
    m = u.microposts.build(content: "test")

    expect(m.content).to eq "test"
  end

  it "vaild with user_id" do
    expect(micropost.user_id).to_not be_nil
    expect(micropost).to be_valid
  end

  it "invalid without user_id" do
    micropost.user_id = nil
    expect(micropost).to_not be_valid
  end

  it "invalid with blank content" do
    micropost.content = "  "
    expect(micropost).to_not be_valid
  end

  it "invalid with content at most 140 characters" do
    micropost.content = "a"*141
    expect(micropost).to_not be_valid
  end

  it "order should be most recent first" do
    FactoryBot.build(:micropost,:create_3years_ago)
    FactoryBot.build(:micropost,:create_2_hours_ago)
    FactoryBot.build(:micropost,:create_10_minutes_ago)
    most_resent_micropost = FactoryBot.create(:micropost)

    expect(Micropost.first).to eq most_resent_micropost
  end

end
