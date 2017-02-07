require 'rspec'
require 'core/use_cases/user'
require 'core/gateways/user/fake_user_repository'
require 'core/domain/environment'
require 'core/domain/id_generator'

describe 'Create user' do
  CreateUser = Core::UseCases::User::Create

  class FakeIdGenerator
    def generate
      new_id = SecureRandom.uuid
      generated << new_id
      new_id
    end

    def generated
      @generated ||= []
    end
  end

  let(:repo) { FakeUserRepository.new }
  let(:env) { Core::Environment.new(FakeIdGenerator.new) }

  it 'requires a username' do
    result = CreateUser.execute(username: '', env: env, repo: repo)
    expect(result).to eql CreateUser::Failure.new(username: :required)
  end

  it 'requires usernames to be unique' do
    CreateUser.execute(username: 'valid name', env: env, repo: repo)
    result = CreateUser.execute(username: 'valid name', env: env, repo: repo)
    expect(result).to eql CreateUser::Failure.new(username: :unique)
  end

  it 'sends an id for the created user back to the handler' do
    result = CreateUser.execute(username: 'valid name', env: env, repo: repo)
    expect(result).to eql CreateUser::Success.new(env.id_generator.generated[0])
  end
end
