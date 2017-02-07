require 'rspec'
require 'core/use_cases/user'
require 'core/gateways/user/fake_user_repository'

describe 'Create user' do
  CreateUser = Core::UseCases::User::Create

  let(:repo) { FakeUserRepository.new }

  it 'requires a username' do
    result = CreateUser.execute(username: '', repo: repo)
    expect(result).to eql CreateUser::Failure.new(username: :required)
  end

  it 'requires usernames to be unique' do
    CreateUser.execute(username: 'valid name', repo: repo)
    result = CreateUser.execute(username: 'valid name', repo: repo)
    expect(result).to eql CreateUser::Failure.new(username: :unique)
  end

  it 'sends an id for the created user back to the handler' do
    result = CreateUser.execute(username: 'valid name', repo: repo)
    expect(result).to be_a CreateUser::Success
    expect(result.created_user_id).to be_a String
  end
end
