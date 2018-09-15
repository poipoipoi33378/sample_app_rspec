module LoginSupport

  def log_in_as(user, password: 'password', remember_me: '1')
    post :create ,  params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end

RSpec.configure do|config|
    config.include LoginSupport
end