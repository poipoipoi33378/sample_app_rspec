require 'rails_helper'

RSpec.feature "Sessions", type: :feature do
  scenario "open login page" do
    visit login_path
    expect(page).to have_current_path "/login"
    expect(page.title).to eq full_title("Log in")
  end

  scenario "success user login" do
    user = FactoryBot.create(:user)
    visit root_path
    click_link "Log in"

    expect(page.title).to eq full_title("Log in")
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path "/users/#{user.id}"
    expect(page).to have_link "Account"
    expect(page).to have_link "Users",href: "#"
    expect(page).to have_link "Profile",href: "/users/#{user.id}"
    expect(page).to have_link "Setting",href: "#"
    expect(page).to have_link "Log out",href: logout_path
    expect(page).to_not have_link "Log in",href: login_path
  end

  scenario "error user login" do
    user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

    expect(page.title).to eq full_title("Log in")
    fill_in "Email", with: user.email
    fill_in "Password", with: "   "
    click_button "Log in"

    expect(page).to have_current_path "/login"
    expect(page).to have_css "div.alert.alert-danger"
    expect(page).to have_content "Invalid email/password combination"

    expect(page).to_not have_link "Account"
    expect(page).to_not have_link "Users",href: ""
    expect(page).to_not have_link "Profile"
    expect(page).to_not have_link "Setting"
    expect(page).to_not have_link "Log out"
    expect(page).to have_link "Log in",href: login_path

    visit root_path
    expect(page).to_not have_css "div.alert.alert-danger"
    expect(page).to_not have_content "Invalid email/password combination"
  end

  scenario "success user logout" do
    user = FactoryBot.create(:user)
    visit root_path
    click_link "Log in"

    expect(page.title).to eq full_title("Log in")
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path "/users/#{user.id}"
    expect(page).to have_link "Account"

    click_on "Account"
    click_on "Log out"

    expect(page).to have_current_path "/"
    expect(page).to_not have_link "Account"
  end

end
