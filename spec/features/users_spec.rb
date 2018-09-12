require 'rails_helper'

RSpec.feature "Users", type: :feature do
  scenario "visit sign up" do
    visit signup_path
    expect(page).to have_current_path "/signup"
  end
end
