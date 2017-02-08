require 'core/entities/user'
def user_repository_contract(repo_class)
  describe "#{repo_class} contract for user repository" do
    let(:justin) { Core::Entities::User.new(username: 'Justin') }
    let(:bob) { Core::Entities::User.new(username: 'Bob') }
    let(:repo) { repo_class.new }
    before do
      repo.save(bob)
      repo.save(justin)
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
