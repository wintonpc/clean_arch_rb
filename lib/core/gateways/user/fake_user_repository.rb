class FakeUserRepository
  def initialize
    @users = []
  end

  def save(user)
    require 'securerandom'
    user.id = SecureRandom.uuid
    @users << user
  end

  def find_by_username(username)
    @users.find { |u| u.username == username }
  end
end
