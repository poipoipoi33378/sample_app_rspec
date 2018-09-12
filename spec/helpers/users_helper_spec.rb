require "rails_helper"

RSpec.describe UsersHelper, :type => :helper do
  describe "garavatar" do

    it "returns imge_tag" do
      user = FactoryBot.build(:user,name: "Example User",email: "example@railstutorial.org")
      expect(helper.gravatar_for(user)).to eq("<img alt=\"Example User\" class=\"gravatar\" src=\"https://secure.gravatar.com/avatar/bebfcf57d6d8277d806a9ef3385c078d?s=80\" />")
    end

    it "returns imge_tag with size=100" do
      user = FactoryBot.build(:user,name: "Example User",email: "example@railstutorial.org")
      expect(helper.gravatar_for(user,size: 100)).to eq("<img alt=\"Example User\" class=\"gravatar\" src=\"https://secure.gravatar.com/avatar/bebfcf57d6d8277d806a9ef3385c078d?s=100\" />")
    end

  end
end
