require 'rails_helper'

RSpec.feature "AccountActivations", type: :feature do
  include ActiveJob::TestHelper

  scenario "user successfully signs up" do

    user = FactoryBot.build(:user)
    visit root_path
    click_link "Sign up now!"

    perform_enqueued_jobs do
      expect do
        fill_in "Name", with: user.name
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        fill_in "Confirmation", with: user.password

        click_button "Create my account"
      end.to change(User, :count).by(1)

      expect(page).to have_content "Please check your email to activate your account."
      expect(current_path).to eq root_path
    end

    mail = ActionMailer::Base.deliveries.last

    aggregate_failures do
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ["noreply@example.com"]
      expect(mail.subject).to eq "Account activation"
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match(CGI.escape(user.email))
    end

    puts mail.body.encoded
    puts token = mail.body.encoded.scan(/account_activations\/(.+?)\//i)

    user = User.find_by(email: user.email)
    # debugger
    # expect(user.authenticated?(:activation, token[0].to_s)).to be_truthy
    user.activation_token = token[0][0]
    expect(user.authenticated?(:activation, user.activation_token)).to be_truthy
    page.driver.submit :get , edit_account_activation_url(user.activation_token,email: user.email),{}

    user = User.first
    expect(page).to have_content "Account activated!"
    expect(current_path).to eq user_path(user)
  end

end
