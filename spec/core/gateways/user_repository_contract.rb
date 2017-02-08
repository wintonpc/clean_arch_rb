require 'core/entities/user'
def user_repository_contract(repo_class)
  describe "#{repo_class} contract for user repository" do
    let(:justin) { Core::Entities::User.new(username: 'Justin') }
    let(:bob) { Core::Entities::User.new(username: 'Bob') }
    let(:repo) { repo_class.new }
    let(:env) { Core::Environment.new(Core::IdGenerator.new) }
    before do
      repo.save(bob, env: env)
      repo.save(justin, env: env)
    end
    it 'finds by name' do
      expect(repo.find_by_username(bob.username)).to eq bob
      expect(repo.find_by_username(justin.username)).to eq justin
    end
    it 'creates unique IDs for users when saved' do
      expect(bob.id).to be
      expect(justin.id).to be
      expect(justin.id).not_to eq(bob.id)
    end
  end
end
