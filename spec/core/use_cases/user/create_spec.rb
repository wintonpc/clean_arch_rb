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
    CreateUser.execute(username: '', env: env, repo: repo) do |r|
      r.assert matches { CreateUser::Failure[validation_errors: {username: :required}] }
    end
  end

  it 'requires usernames to be unique' do
    CreateUser.execute(username: 'valid name', env: env, repo: repo) do |r|
      r.assert matches { CreateUser::Success }
    end
    CreateUser.execute(username: 'valid name', env: env, repo: repo) do |r|
      r.assert matches { CreateUser::Failure[validation_errors: {username: :unique}] }
    end
  end

  it 'sends an id for the created user back to the handler' do
    CreateUser.execute(username: 'valid name', env: env, repo: repo) do |r|
      r.assert matches { CreateUser::Success[created_user_id: !env.id_generator.generated[0]] }
    end
  end

  it 'case handled' do
    result = CreateUser.execute(username: 'valid name', env: env, repo: repo) do |r|
      r.when matches { CreateUser::Success[created_user_id] } do |matched|
        "Created user #{matched.created_user_id}"
      end
      r.when matches { CreateUser::Failure[validation_errors: {username: :required}] } do
        'Validation failed because username was not provided'
      end
      r.when matches { CreateUser::Failure[validation_errors: {username: :unique}] } do
        'Validation failed because username was not unique'
      end
    end
    expect(result).to eql "Created user #{env.id_generator.generated[0]}"
  end

  it 'case not handled' do
    expect do
      CreateUser.execute(username: 'valid name', env: env, repo: repo) do |r|
        r.when matches { CreateUser::Failure[validation_errors: {username: :required}] } do
          'Validation failed because username was not provided'
        end
        r.when matches { CreateUser::Failure[validation_errors: {username: :unique}] } do
          'Validation failed because username was not unique'
        end
      end
    end.to raise_error /Failed to match/
  end
end
