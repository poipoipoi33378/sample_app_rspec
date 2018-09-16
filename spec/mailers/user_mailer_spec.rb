require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "mail message" do

    it "account_activation" do
      user = FactoryBot.build(:user)
      user.activation_token = User.new_token
      mail = UserMailer.account_activation(user)

      expect(mail.subject).to eq("Account activation")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@example.com"])

      expect(mail.body.encoded).to match("Hi #{user.name}")
      expect(mail.body.encoded).to match(user.activation_token)
      expect(mail.body.encoded).to match(CGI.escape(user.email))
    end
  end
end
