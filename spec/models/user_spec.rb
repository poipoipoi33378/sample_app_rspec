require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  it "create user" do
    expect(@user).to be_valid
  end

  it "is invalid with blank name" do
    @user.name = "  "
    expect(@user).to_not be_valid
  end

  it "is invalid with blank email" do
    @user.email = "  "
    expect(@user).to_not be_valid
  end

  it "is invalid with too long name" do
    @user.name = "a" * 51
    expect(@user).to_not be_valid
  end

  it "is invalid with too long email" do
    @user.email = "a" * 244 + "@example.com"
    expect(@user).to_not be_valid
  end

  it "is list of valid emailes" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      expect(@user).to be_valid
    end
  end

  it "is list of invalid emails" do
    invalid_addresses = %w[foo@bar..com user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      expect(@user).to_not be_valid
    end
  end

  it "is invalid with duplicate address" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    expect(duplicate_user).to_not be_valid
  end

  it "is downcase email with save db" do
    @user.email = @user.email.upcase
    expect(@user).to be_valid

    @user.save
    expect(@user.email).to eq(@user.email.downcase)
  end

  it "is invalid with blank password" do
    @user.password = @user.password_confirmation = " " * 6

    @user.valid?
    expect(@user.errors[:password]).to include("can't be blank")
  end

  it "is invalid with short password" do
    @user.password = @user.password_confirmation = "a" * 5

    @user.valid?
    expect(@user.errors[:password]).to include("is too short (minimum is 6 characters)")
  end

end
