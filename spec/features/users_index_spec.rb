require 'rails_helper'

RSpec.feature "UsersIndexSpec.rbs", type: :feature  do
  feature "show all user profile" do
    before do
      @admin_user = FactoryBot.create(:user,:admin)
      @normal_user = FactoryBot.create(:user)
      @delete_user = FactoryBot.create(:user)

      50.times.each do
        FactoryBot.create(:user)
      end
    end

    context "with admin user" do
      # scenario "index including pagination" ,driver: :selenium do
      scenario "admin user show users profile and delete" ,js: true do

        user = @admin_user
        visit root_path
        click_link "Log in"
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_button "Log in"

        click_link "Users"
        expect(page).to have_current_path '/users'
        expect(page).to have_css 'div.pagination',count:2
        User.paginate(page: 1).each do |user|
          expect(page).to have_link user.name,href: user_path(user)
          unless user.admin?
            expect(page).to have_link "delete",href: user_path(user)
          end
        end

        # delete cancel
        expect do
          click_link "delete",href: user_path(@delete_user)
          page.driver.browser.switch_to.alert.dismiss
        end.to_not change(User,:count)

        # delete ok
        expect do
          click_link "delete",href: user_path(@delete_user)
          page.driver.browser.switch_to.alert.accept

          expect(page).to have_content "User deleted"
          User.paginate(page: 1).each do |user|
            expect(page).to_not have_link user.name,href: user_path(@delete_user)
          end
        end.to change(User,:count).by(-1)

        expect(User.find_by(email: @delete_user.email)).to be_nil
      end
    end

    context "without admin user" do
      scenario "cant not delete user" do
        user = @normal_user

        page.driver.submit :delete, user_path(@delete_user),{}
        expect(page).to have_current_path login_url

        visit root_path
        click_link "Log in"
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_button "Log in"

        click_link "Users"
        User.paginate(page: 1).each do |user|
          expect(page).to have_link user.name,href: user_path(user)
          expect(page).to_not have_link "delete",href: user_path(user)
        end

        # delete
        expect do
          page.driver.submit :delete, user_path(@delete_user),{}
          expect(page).to have_current_path root_path
        end.to_not change(User,:count)
      end
    end
  end

  scenario "redirect index when not looged in" do

    visit users_path
    expect(page).to have_current_path login_path
  end

end
