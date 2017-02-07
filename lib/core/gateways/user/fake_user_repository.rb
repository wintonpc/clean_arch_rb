class FakeUserRepository
  def initialize
    @users = []
  end

  def save(user, env:)
    user.id = env.id_generator.generate
    @users << user
  end

  def find_by_username(username)
    @users.find { |u| u.username == username }
  end
end
