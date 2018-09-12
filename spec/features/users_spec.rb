require 'rails_helper'

RSpec.feature "Users", type: :feature do
  scenario "visit sign up" do
    visit signup_path
    expect(page).to have_current_path "/signup"
  end

  scenario "create my account" do
    user = FactoryBot.build(:user)
    visit signup_path

    fill_in "Name", with: user.name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Confirmation", with: user.password

    expect do
      click_button "Create my account"
      expect(page).to_not have_css "div#error_explanation"
      expect(page).to_not have_css "div.field_with_errors"
      expect(page).to have_css "div.alert.alert-success"
      expect(page).to have_content "Welcome to the Sample App!"
      expect(page).to have_current_path "/users/1"
    end.to change(User, :count).by(1)
  end

  scenario "create my account error" do
    user = FactoryBot.build(:user,password: " " * 6)
    visit signup_path

    fill_in "Name", with: user.name
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    fill_in "Confirmation", with: user.password

    expect do
      click_button "Create my account"
      expect(page).to have_content "The form contains 1 error."
      expect(page).to have_css "div#error_explanation"
      expect(page).to have_css "div.field_with_errors"

      expect(page).to have_current_path "/signup"
    end.to_not change(User, :count)
  end

end
