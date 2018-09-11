require 'rails_helper'

RSpec.feature "StaticPages", type: :feature do
  scenario "visit root" do
    visit root_path
    expect(page.title).to eq full_title
  end

  scenario "click help " do
    visit root_path
    click_link "Help"

    expect(page.title).to eq full_title("Help")
  end

  scenario "click about " do
    visit root_path
    click_link "About"

    expect(page.title).to eq full_title("About")
  end

  scenario "click contact " do
    visit root_path
    click_link "Contact"

    expect(page.title).to eq full_title("Contact")
  end

  scenario "click sample app " do
    visit root_path
    click_link "sample app"

    expect(page.title).to eq full_title
  end

  scenario "click sing up " do
    visit root_path
    click_link "Sign up now!"

    expect(page.title).to eq full_title("Sign up")
  end

end
