require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do
  describe "#page_title" do
    before do
      @base_title =  "Ruby on Rails Tutorial Sample App"
    end

    it "returns the default title" do
      expect(helper.full_title).to eq(@base_title)
    end

    it "returns the default about title" do
      expect(helper.full_title("About")).to eq("About | " + @base_title)
    end

  end
end