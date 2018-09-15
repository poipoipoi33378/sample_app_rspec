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

    expect(page).to have_current_path user_path(user)
    expect(page).to have_link "Account"
    expect(page).to have_link "Users",href: users_path
    expect(page).to have_link "Profile",href: user_path(user)
    expect(page).to have_link "Setting",href: edit_user_path(user)
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

    # for forget error
    page.driver.delete(logout_path)

    expect(page).to_not have_link "Log out"
    expect(page).to have_link "Log in",href: login_path
  end

  scenario "user login with Remember me and login again",driver: :selenium do

    user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    check "Remember me on this computer"
    click_button "Log in"

    expect(page).to have_current_path "/users/#{user.id}"
    expect(page).to have_link "Account"

    # show_me_the_cookies
    # puts get_me_the_cookie("remember_token")
    # puts get_me_the_cookie("user_id")

    expire_cookies

    # show_me_the_cookies
    # puts get_me_the_cookie("remember_token")
    # puts get_me_the_cookie("user_id")

    visit root_path
    expect(page).to have_link "Account"
    expect(page).to_not have_link "Log in"
  end

  scenario "user login without Remember me and login again error",driver: :selenium do

    user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

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
