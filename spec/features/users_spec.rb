require 'rails_helper'

RSpec.feature "Users", type: :feature do

  feature "sing up" do
    before do
      @user = FactoryBot.build(:user)
      visit signup_path
    end

    scenario "create my account" do
      # -> account_actiovations_spec
    end

    scenario "create my account error" do
      fill_in "Name", with: @user.name
      fill_in "Email", with: @user.email
      fill_in "Password", with: " " * 6
      fill_in "Confirmation", with: @user.password

      expect do
        click_button "Create my account"
        expect(page).to have_content "The form contains 1 error."
        expect(page).to have_css "div#error_explanation"
        expect(page).to have_css "div.field_with_errors"
        expect(page).to have_current_path "/signup"
      end.to_not change(User, :count)
    end
  end

  feature "log in" do
    scenario "activated user can log in" do
      user = FactoryBot.create(:user)
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)

      visit root_path
      click_link "Log in"

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"

      expect(page).to have_link "Account"
      expect(page).to have_current_path user_path(user)
    end

    scenario "user can not log in without activate" do
      user = FactoryBot.create(:user)
      user.update_attribute(:activated,    false)
      user.update_attribute(:activated_at, nil)
      user.save
      expect(user).to_not be_activated

      visit root_path
      click_link "Log in"

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"

      message  = "Account not activated. "
      message += "Check your email for the activation link."
      expect(page).to have_content message
      expect(page).to have_current_path root_path

    end

  end

  feature "show profile" do
    scenario "not visit unactivated user profile" do
      user = FactoryBot.create(:user)
      not_activated_user = FactoryBot.create(:user,activated: false)

      visit root_path
      click_link "Log in"

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"

      visit user_path(not_activated_user)
      expect(page).to have_current_path root_path
    end

    scenario "show user profile and microposts" do
      user = FactoryBot.create(:user)

      50.times do |i|
        user.microposts.create(content: "test#{i}")
      end
      expect(Micropost.count).to eq 50

      visit root_path
      click_link "Log in"

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"

      visit user_path(user)

      expect(page).to have_title(full_title(user.name))
      expect(page).to have_css 'div.pagination'
      expect(page).to have_content "Microposts (#{user.microposts.count})"
      expect(find("h1 img.gravatar")).to_not be_nil
      user.microposts.paginate(page: 1).each do |micropost|
        expect(page).to have_content micropost.content
      end
    end
  end

  feature "edit profile" do
    context "with log in" do
      before do
        @user = FactoryBot.create(:user)

        visit root_path
        click_link "Log in"

        fill_in "Email", with: @user.email
        fill_in "Password", with: @user.password
        click_button "Log in"

        click_link "Account"
        click_link "Setting"
      end

      scenario "edit user profile" do
        expect(page).to have_current_path "/users/#{@user.id}/edit"
        expect(page).to have_title full_title("Edit user")

        set_test_name = "Check Name Change"
        expect do
          fill_in "Name", with: set_test_name
          fill_in "Email", with: @user.email
          fill_in "Password", with: @user.password
          fill_in "Confirmation", with: @user.password

          expect(page).to have_link('change', :href => "http://gravatar.com/emails")
          click_button "Save changes"
        end.to_not change(User, :count)

        expect(page).to have_current_path "/users/#{@user.id}"
        @user.reload
        expect(@user.name).to eq(set_test_name)
      end

      scenario "edit user profile without password" do

        test_name = "Check Name Change"
        test_email = "test@email.com"
        before_password = @user.password_digest
        expect do
          fill_in "Name", with: test_name
          fill_in "Email", with: test_email
          fill_in "Password", with: ""
          fill_in "Confirmation", with: ""

          click_button "Save changes"
        end.to_not change(User, :count)

        expect(page).to have_content "Profile updated"
        @user.reload

        expect(@user.name).to eq(test_name)
        expect(@user.email).to eq(test_email)
        expect(@user.password_digest).to eq(before_password)
      end

      scenario "edit user profile error" do

        before_email = @user.email
        before_name = @user.name
        before_password = @user.password_digest
        expect do
          fill_in "Name", with: "a"*51
          fill_in "Email", with: "test"
          fill_in "Password", with: ""
          fill_in "Confirmation", with: ""

          click_button "Save changes"
        end.to_not change(User, :count)

        expect(page).to have_css "div.alert.alert-danger"
        expect(page).to have_content "The form contains 2 errors."

        @user.reload

        expect(@user.name).to eq(before_name)
        expect(@user.email).to eq(before_email)
        expect(@user.password_digest).to eq(before_password)
      end

      scenario "can not update admin" do

        expect(@user).to_not be_admin
        page.driver.submit :patch, user_path(@user),
                           { id: @user.id,user: { email: @user.email, name: "test name",admin: true} }

        @user.reload
        expect(@user.name).to eq("test name")
        expect(@user).to_not be_admin
      end
    end

    context "can not edit profile without log in" do
      before do
        @user = FactoryBot.create(:user)
      end

      scenario "can not edit prifile.return login page" do

        visit edit_user_path(@user)
        expect(page).to have_current_path "/login"

        expect(page).to have_css "div.alert.alert-danger"
        expect(page).to have_content "Please log in."
      end

      scenario "can not update profile. return login page" do

        page.driver.submit :patch, user_path(@user), { id: @user.id,user: { email: @user.email, name: @user.name} }
        expect(page).to have_current_path "/login"

        expect(page).to have_css "div.alert.alert-danger"
        expect(page).to have_content "Please log in."
      end
    end

    context "can not edit other user profile" do
      before do
        @user = FactoryBot.create(:user)
        @other_user = FactoryBot.create(:user)

        # Log in
        page.driver.post login_path,
                         { session: { email: @user.email, password: @user.password, remember_me: 1 } }
        visit root_path
      end
      scenario "can not edit other user" do

        expect(page).to have_link "Account"
        visit edit_user_path(@other_user)
        expect(page).to have_current_path root_url
      end

      scenario "can not update other user profile" do

        expect(page).to have_link "Account"
        page.driver.submit :patch, user_path(@other_user),
                           { id: @other_user.id,user: { email: @user.email, name: @user.name} }

        expect(page).to have_current_path root_url
      end
    end
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
end
