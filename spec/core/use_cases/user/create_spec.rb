require 'rspec'
require 'core/use_cases/user'
require 'core/gateways/user/fake_user_repository'

describe 'Create user' do
  CreateUser = Core::UseCases::User::Create

  class HandlerSpy
    attr_reader :spy_validation_errors, :spy_created_user_id

    def validation_failed(errors)
      @spy_validation_errors = errors
    end

    def user_created(id)
      @spy_created_user_id = id
    end
  end

  let(:handler) { HandlerSpy.new }
  let(:repo) { FakeUserRepository.new }

  it 'requires a username' do
    CreateUser.execute(username: '', handler: handler, repo: repo)
    expect(handler.spy_validation_errors).to include(username: :required)
  end

  it 'requires usernames to be unique' do
    CreateUser.execute(username: 'valid name', handler: handler, repo: repo)
    CreateUser.execute(username: 'valid name', handler: handler, repo: repo)
    expect(handler.spy_validation_errors).to include(username: :unique)
  end

  it 'sends an id for the created user back to the handler' do
    CreateUser.execute(username: 'valid name', handler: handler, repo: repo)
    expect(handler.spy_created_user_id).to be
  end
end
