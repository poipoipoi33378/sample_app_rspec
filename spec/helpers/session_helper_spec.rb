require "rails_helper"

RSpec.describe SessionsHelper, :type => :helper do
  describe "Session Helper" do

    it "current_user returns right when login" do
      user = FactoryBot.create(:user)
      helper.log_in(user)

      expect(helper.current_user).to eq(user)
      expect(helper.logged_in?).to be_truthy
    end

    it "current_user returns right when session is nil" do
      user = FactoryBot.create(:user)
      helper.remember(user)

      expect(helper.current_user).to eq(user)
      expect(helper.logged_in?).to be_truthy
    end

    it "current_user returns nil when remember digest is wrong" do
      user = FactoryBot.create(:user)
      helper.remember(user)

      invalid_new_token = User.digest(User.new_token)
      user.update_attribute(:remember_digest, invalid_new_token)
      expect(helper.current_user).to be_nil
    end
  end
end