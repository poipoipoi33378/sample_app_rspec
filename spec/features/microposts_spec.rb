require 'rails_helper'

RSpec.feature "Microposts", type: :feature do
  include ActionDispatch::TestProcess

  scenario "can not creat without login"  do
    expect do
      page.driver.submit :post, microposts_path,params:{micropost:{content: "Lorem ipsum"}}
    end.to_not change(Micropost,:count)

    expect(page).to have_current_path login_path

    expect(page).to have_css "div.alert.alert-danger"
    expect(page).to have_content "Please log in."
  end

  scenario "can not delete without login" do
    visit root_path

    micropost = FactoryBot.create(:micropost)
    expect do
      page.driver.submit :delete, micropost_path(micropost),{}
    end.to_not change(Micropost,:count)
    expect(page).to have_current_path login_path

    expect(page).to have_css "div.alert.alert-danger"
    expect(page).to have_content "Please log in."
  end

  scenario "create micropost when login user" do
    user = FactoryBot.create(:user)
    expect(User.count).to eq 1

    visit login_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    visit root_path
    expect(page).to have_content user.name

    expect(find('span.picture input#micropost_picture')).to_not be_nil
    expect do
      click_button "Post"
      expect(page).to have_content "The form contains 1 error."
    end.to_not change(Micropost,:count)

    expect do
      fill_in "micropost_content",with: "test test"
      click_button "Post"
    end.to change(Micropost,:count).by(1)

    content = "This micropost really ties the room together"
    picture = fixture_file_upload('rails.png')

    expect do
      page.driver.submit :post, microposts_path,
                         { micropost: { content: content, picture: picture } }
    end.to change(Micropost,:count).by(1)

    expect(page).to have_content "Micropost created!"
  end

  scenario "show microposts with home" ,js: true do
    user = FactoryBot.create(:user)
    ohter_user = FactoryBot.create(:user)
    50.times do |i|
      user.microposts.create(content: "test#{i}")
    end
    delete_micropost = user.microposts.create(content: "test#{0}")
    50.times do |i|
      ohter_user.microposts.create(content: "other test#{i}")
    end

    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    visit root_path
    expect(page).to have_content user.name
    user.microposts.paginate(page: 1).each do |micropost|
      expect(page).to have_content micropost.content
      expect(page).to have_link "delete",href: micropost_path(micropost)
    end

    # delete cancel
    expect do
      click_link "delete",href: micropost_path(delete_micropost)
      page.driver.browser.switch_to.alert.dismiss
    end.to_not change(Micropost,:count)

    # delete ok
    expect do
      click_link "delete",href: micropost_path(delete_micropost)
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content "Micropost deleted"
      expect(page).to_not have_link "delete",href: micropost_path(delete_micropost)
    end.to change(Micropost,:count).by(-1)

    visit user_path(ohter_user)
    ohter_user.microposts.paginate(page: 1).each do |micropost|
      expect(page).to have_content micropost.content
      expect(page).to_not have_link "delete",href: micropost_path(micropost)
    end

  end

end
