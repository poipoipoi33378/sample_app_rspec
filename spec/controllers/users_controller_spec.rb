require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "GET" do
    it "returns http success with new" do
      get :new
      expect(response).to have_http_status("200")
    end

    it "returns http success with show" do
      get :show, params: { id: 1 }
      expect(response).to have_http_status("200")
    end

  end

end
