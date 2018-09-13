require 'rails_helper'

RSpec.describe User, type: :model do

  it "has a valid factory" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  it "create user" do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end

  it "is invalid with blank name" do
    user = FactoryBot.build(:user,name: "   ")
    expect(user).to_not be_valid
  end

  it "is invalid with blank email" do
    user = FactoryBot.build(:user,email: "   ")
    expect(user).to_not be_valid
  end

  it "is invalid with too long name" do
    user = FactoryBot.build(:user,name: "a" * 51)
    expect(user).to_not be_valid
  end

  it "is invalid with too long email" do
    user = FactoryBot.build(:user,email: "a" * 244 + "@example.com")
    expect(user).to_not be_valid
  end

  it "is list of valid emailes" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      user = FactoryBot.build(:user,email: valid_address)
      expect(user).to be_valid
    end
  end

  it "is list of invalid emails" do
    invalid_addresses = %w[foo@bar..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      user = FactoryBot.build(:user,email: invalid_address)
      expect(user).to_not be_valid
    end
  end

  it "is invalid with duplicate address" do
    FactoryBot.create(:user)
    user = FactoryBot.build(:user)
    user.email.upcase!
    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "is downcase email with save db" do
    user = FactoryBot.build(:user)
    user.email = user.email.upcase
    expect(user).to be_valid

    user.save
    expect(user.email).to eq(user.email.downcase)
  end

  it "is invalid with blank password" do
    user = FactoryBot.build(:user,password: " " * 6)

    user.valid?
    expect(user.errors[:password]).to include("can't be blank")
  end

  it "is invalid with short password" do
    user = FactoryBot.build(:user,password: "a" * 5)

    user.valid?
    expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
  end

  it "return digest" do
    expect(User.digest("test")).to_not eq "$2a$04$nYrtOxM4U3q4L/cf.xsBC.Ltv1nrfcEKcTAdNo88P.nbTMDW4yE4a"
  end
end
