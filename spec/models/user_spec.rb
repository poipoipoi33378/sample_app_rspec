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
    FactoryBot.create(:user,:email => "test@email.com")
    user = FactoryBot.build(:user,:email => "test@email.com")
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

  it "user authenticate" do
    user = FactoryBot.build(:user)
    user.remember
    expect(user).to be_authenticated(:remember,user.remember_token)
    expect(user).to_not be_authenticated(:remember,"dammy")
  end

  it "returns false with user with nil digest" do
    user = FactoryBot.build(:user)
    user.remember_digest = nil
    expect(user).to_not be_authenticated(:remember,"")
  end

  it "create activation_digest before user create" do
    user = FactoryBot.build(:user)
    expect(user.activation_digest).to be_nil
    expect(user.activation_token).to be_nil

    user.save
    expect(user.activation_digest).to_not be_nil
    expect(user.activation_token).to_not be_nil
  end

  it "delete microposts" do
    user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
    user.save
    user.microposts.create!(content: "Lorem ipsum")
    expect do
      user.destroy
    end.to change(Micropost,:count).by(-1)
  end

  it "follow and unfollow a user" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)

    expect(user1).to_not be_following(user2)
    user1.follow(user2)
    expect(user1).to be_following(user2)
    expect(user2.followers.include?(user1)).to be_truthy
    user1.unfollow(user2)
    expect(user1).to_not be_following(user2)
    expect(user2.followers.include?(user1)).to be_falsey
  end

  it "feed have the right posts" do

    michael = FactoryBot.create(:user,name: "michael")
    archer = FactoryBot.create(:user,name: "archer")
    lana = FactoryBot.create(:user,name: "lana")

    michael.follow(lana)
    4.times do
      michael.microposts.create(content: "Mytext")
      archer.microposts.create(content: "Mytext")
      lana.microposts.create(content: "Mytext")
    end

    # フォローしているユーザーの投稿を確認
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # 自分自身の投稿を確認
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # フォローしていないユーザーの投稿を確認
    archer.microposts.each do |post_unfollowed|
      expect(michael.feed.include?(post_unfollowed)).to be_falsey
    end
  end

end
