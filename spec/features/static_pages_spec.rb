require 'rails_helper'

RSpec.feature "StaticPages", type: :feature do

  before do
    visit root_path
  end
  scenario "visit root" do
    expect(page.title).to eq full_title
  end

  scenario "click help " do
    click_link "Help"
    expect(page.title).to eq full_title("Help")
  end

  scenario "click about " do
    click_link "About"
    expect(page.title).to eq full_title("About")
  end

  scenario "click contact " do
    click_link "Contact"
    expect(page.title).to eq full_title("Contact")
  end

  scenario "click sample app " do
    click_link "sample app"
    expect(page.title).to eq full_title
  end

  scenario "click sing up " do
    click_link "Sign up now!"
    expect(page.title).to eq full_title("Sign up")
  end

  scenario "click login page" do
    click_link "Log in"
    expect(page.title).to eq full_title("Log in")
  end

end
