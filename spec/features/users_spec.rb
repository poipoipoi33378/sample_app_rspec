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
      # for check login menu
      expect(page).to have_link "Account"

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

  scenario "edit user profile" do
    user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    click_link "Account"
    click_link "Setting"

    expect(page).to have_current_path "/users/#{user.id}/edit"
    expect(page).to have_title full_title("Edit user")


    set_test_name = "Check Name Change"
    expect do
      fill_in "Name", with: set_test_name
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      fill_in "Confirmation", with: user.password

      expect(page).to have_link('change', :href => "http://gravatar.com/emails")

      click_button "Save changes"
    end.to_not change(User, :count)

    expect(page).to have_current_path "/users/#{user.id}"
    user.reload
    expect(user.name).to eq(set_test_name)
  end

  scenario "edit user profile without password" do
    user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    click_link "Account"
    click_link "Setting"

    expect(page).to have_current_path "/users/#{user.id}/edit"
    expect(page).to have_title full_title("Edit user")


    test_name = "Check Name Change"
    test_email = "test@email.com"
    before_password = user.password_digest
    expect do
      fill_in "Name", with: test_name
      fill_in "Email", with: test_email
      fill_in "Password", with: ""
      fill_in "Confirmation", with: ""

      click_button "Save changes"
    end.to_not change(User, :count)

    expect(page).to have_content "Profile updated"

    user.reload

    expect(user.name).to eq(test_name)
    expect(user.email).to eq(test_email)
    expect(user.password_digest).to eq(before_password)
  end

  scenario "edit user profile error" do
    user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    click_link "Account"
    click_link "Setting"

    expect(page).to have_current_path "/users/#{user.id}/edit"
    expect(page).to have_title full_title("Edit user")


    before_email = user.email
    before_name = user.name
    before_password = user.password_digest
    expect do
      fill_in "Name", with: "a"*51
      fill_in "Email", with: "test"
      fill_in "Password", with: ""
      fill_in "Confirmation", with: ""

      click_button "Save changes"
    end.to_not change(User, :count)

    expect(page).to have_css "div.alert.alert-danger"
    expect(page).to have_content "The form contains 2 errors."

    user.reload

    expect(user.name).to eq(before_name)
    expect(user.email).to eq(before_email)
    expect(user.password_digest).to eq(before_password)
  end

  scenario "can not edit without login" do
    user = FactoryBot.create(:user)

    visit edit_user_path(user)
    expect(page).to have_current_path "/login"

    expect(page).to have_css "div.alert.alert-danger"
    expect(page).to have_content "Please log in."
  end

  scenario "can not update without login" do
    user = FactoryBot.create(:user)

    page.driver.submit :patch, user_path(user), { id: user.id,user: { email: user.email, name: user.name} }

    expect(page).to have_current_path "/login"

    expect(page).to have_css "div.alert.alert-danger"
    expect(page).to have_content "Please log in."
  end

  scenario "can not update other user profile" do
    user = FactoryBot.create(:user)
    other_user = FactoryBot.create(:user)

    # Log in
    page.driver.post login_path,
                      { session: { email: user.email, password: user.password, remember_me: 1 } }

    visit root_path
    expect(page).to have_link "Account"

    page.driver.submit :patch, user_path(other_user),
                       { id: other_user.id,user: { email: user.email, name: user.name} }

    expect(page).to have_current_path root_url
  end

  scenario "can not update admin" do
    user = FactoryBot.create(:user)
    expect(user).to_not be_admin

    # Log in
    page.driver.post login_path,
                     { session: { email: user.email, password: user.password, remember_me: 1 } }

    visit root_path
    expect(page).to have_link "Account"

    page.driver.submit :patch, user_path(user),
                       { id: user.id,user: { email: user.email, name: "test name",admin: true} }

    user.reload
    expect(user.name).to eq("test name")
    expect(user).to_not be_admin
  end

  scenario "can not edit other user" do
    user = FactoryBot.create(:user)
    other_user = FactoryBot.create(:user)

    visit root_path
    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    visit edit_user_path(other_user)
    expect(page).to have_current_path root_url
  end

  scenario "edit user with friendly forwarding" do
    user = FactoryBot.create(:user)

    visit edit_user_path(user)
    expect(page).to have_current_path "/login"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path "/users/#{user.id}/edit"
    expect(page).to have_title full_title("Edit user")

    click_link "Account"
    click_link "Log out"

    expect(page).to have_current_path "/"

    click_link "Log in"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path user_path(user)
  end

  scenario "redirect index when not looged in" do

    visit users_path
    expect(page).to have_current_path login_path
  end

end
