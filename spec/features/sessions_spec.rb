require 'rails_helper'

RSpec.feature "Sessions", type: :feature do

  let(:user) { FactoryBot.create(:user) }

  before do
    visit root_path
    click_link "Log in"
  end

  scenario "success user login and log out" do
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path user_path(user)
    expect(page).to have_link "Account"
    expect(page).to have_link "Users",href: users_path
    expect(page).to have_link "Profile",href: user_path(user)
    expect(page).to have_link "Setting",href: edit_user_path(user)
    expect(page).to have_link "Log out",href: logout_path
    expect(page).to_not have_link "Log in",href: login_path

    click_on "Account"
    click_on "Log out"

    expect(page).to have_current_path "/"
    expect(page).to_not have_link "Account"

    # check logout direct
    page.driver.delete(logout_path)

    expect(page).to_not have_link "Log out"
    expect(page).to have_link "Log in"
  end

  scenario "error user login" do
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

    # for check disappear　alert
    visit root_path
    expect(page).to_not have_css "div.alert.alert-danger"
    expect(page).to_not have_content "Invalid email/password combination"
  end

  scenario "user login with Remember me and login again",driver: :selenium do
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    check "Remember me on this computer"
    click_button "Log in"

    expect(page).to have_current_path "/users/#{user.id}"
    expect(page).to have_link "Account"

    # clear session key
    expire_cookies

    visit root_path
    expect(page).to have_link "Account"
    expect(page).to_not have_link "Log in"
  end

  scenario "user login without Remember me. can not auto login",driver: :selenium do

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    uncheck "Remember me on this computer"
    click_button "Log in"

    expect(page).to have_current_path "/users/#{user.id}"
    expect(page).to have_link "Account"

    expire_cookies

    visit root_path
    expect(page).to_not have_link "Account"
    expect(page).to have_link "Log in"
  end

end
