require 'rails_helper'

RSpec.feature "StaticPages", type: :feature do
  before do
    @base_title =  "Ruby on Rails Tutorial Sample App"
  end

  scenario "user visit root" do
    visit root_path
    expect(page.title).to eq "Home | #{@base_title}"
  end

  scenario "user visit home" do
    visit static_pages_home_path
    expect(page.title).to eq "Home | #{@base_title}"
  end

  scenario "user visit help " do
    visit static_pages_help_path
    expect(page.title).to eq "Help | #{@base_title}"
  end

  scenario "user visit about " do
    visit static_pages_about_path
    expect(page.title).to eq "About | #{@base_title}"
  end

  scenario "user visit contact " do
    visit static_pages_contact_path
    expect(page.title).to eq "Contact | #{@base_title}"
  end
end
