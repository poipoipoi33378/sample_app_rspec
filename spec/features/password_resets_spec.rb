require 'rails_helper'

RSpec.feature "PasswordResets", type: :feature do
  include ActiveJob::TestHelper

  before do
    ActionMailer::Base.deliveries.clear
  end

  scenario "reset password"  do
  # scenario "reset password" ,driver: :selenium do
    user = FactoryBot.create(:user)

    visit login_path
    click_link "(forgot password)"

    perform_enqueued_jobs do
      expect(current_path).to eq new_password_reset_path

      fill_in "Email", with: "raise_error@raise.co.jj"
      click_button "Submit"

      expect(current_path).to eq '/password_resets'
      expect(page).to have_content("Email address not found")

      visit root_path
      expect(page).to_not have_content("Email address not found")

      visit new_password_reset_path
      fill_in "Email", with: user.email
      click_button "Submit"

      expect(current_path).to eq root_path
      expect(page).to have_content("Email sent with password reset instructions")

      visit root_path
      expect(page).to_not have_content("Email sent with password reset instructions")

      user.reload
      expect(user.reset_digest).to_not be_nil
    end

    expect(ActionMailer::Base.deliveries.size).to eq 1
    mail = ActionMailer::Base.deliveries.last
    aggregate_failures do
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ["noreply@example.com"]
      expect(mail.subject).to eq "Password reset"
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match(CGI.escape(user.email))

    end

    puts token = mail.body.encoded.scan(/password_resets\/(.+?)\//i)
    user = User.find_by(email: user.email)

    # invalid reset_token
    user.reset_token = "dummytoken"
    page.driver.submit :get , edit_password_reset_url("testtest",email: user.email),{}
    expect(current_path).to eq root_path

    # vaild reset_token
    user.reset_token = token[0][0]
    expect(user.authenticated?(:reset, user.reset_token)).to be_truthy
    page.driver.submit :get , edit_password_reset_url(user.reset_token,email: user.email),{}

    expect(page).to have_content "Reset password"
    expect(find('#email',visible: false).value).to eq user.email

    # パスワード再設定の有効期限が切れていないか
    user.update_attribute(:reset_sent_at,4.hours.ago)
    user.password = "new password"
    fill_in "Password", with: user.password
    fill_in "Confirmation", with: user.password
    click_button("Update password")
    expect(page).to have_content("Password reset has expired.")

    user.update_attribute(:reset_sent_at,Time.zone.now)

    page.driver.submit :get , edit_password_reset_url(user.reset_token,email: user.email),{}
    # 無効なパスワードであれば失敗させる (失敗した理由も表示する)
    user.password = "ttt"
    fill_in "Password", with: user.password
    fill_in "Confirmation", with: user.password
    click_button("Update password")
    expect(page).to have_content("The form contains 1 error.")
    expect(page).to have_content("Password is too short (minimum is 6 characters)")

    # 新しいパスワードが空文字列になっていないか (ユーザー情報の編集ではOKだった)
    user.password = ""
    fill_in "Password", with: ""
    fill_in "Confirmation", with: ""
    click_button("Update password")
    expect(page).to have_content("The form contains 1 error.")
    expect(page).to have_content("Password can't be blank")

    user.password = "new password"
    fill_in "Password", with: user.password
    fill_in "Confirmation", with: user.password
    click_button("Update password")

    expect(current_path).to eq user_path(user)
    expect(page).to have_link("Account")
    expect(page).to have_content "Password has been reset."

    # log in using new password
    click_link "Log out"
    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button("Log in")
    expect(page).to have_link("Log out")
  end
end
