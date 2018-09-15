require 'rails_helper'

RSpec.feature "UsersIndexSpec.rbs", type: :feature  do
  # scenario "index including pagination" ,driver: :selenium do
  scenario "index including pagination" ,js: true do
    user = FactoryBot.create(:user,:admin)
    delete_user = FactoryBot.create(:user,:admin)

    50.times.each do
      FactoryBot.create(:user)
    end

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

    # delete
    expect do
      click_link "delete",href: user_path(delete_user)
      page.driver.browser.switch_to.alert.dismiss
    end.to_not change(User,:count)


    expect do
      click_link "delete",href: user_path(delete_user)
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content "User deleted"
    end.to change(User,:count).by(-1)

    User.paginate(page: 1).each do |user|
      expect(page).to_not have_link user.name,href: user_path(delete_user)
    end

    expect(User.find_by(email: delete_user.email)).to be_nil
  end

  scenario "cant not delete user" do
    user = FactoryBot.create(:user)
    delete_user = FactoryBot.create(:user)

    50.times.each do
      FactoryBot.create(:user)
    end

    page.driver.submit :delete, user_path(delete_user),{}
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

    page.driver.submit :delete, user_path(delete_user),{}
    expect(page).to have_current_path root_path

  end

  scenario "factory test"  do
    expect(FactoryBot.build(:user)).to_not be_admin
    expect(FactoryBot.build(:user,:admin)).to be_admin
  end

end
