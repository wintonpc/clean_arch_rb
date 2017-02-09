require 'rspec'
require 'helpers/make_a_spy_for_contract'
require 'core/use_cases/user/create_user_contract'
require 'core/use_cases/user'
require 'core/gateways/user/fake_user_repository'

describe Core::UseCases::User::Create do
  let(:handler) { SpecHelpers::MakeASpyForContract.(UserCreateContract) }
  let(:repo) { FakeUserRepository.new }
  subject { Core::UseCases::User::Create }

  def create_valid_user
    subject.(username: 'valid name', handler: handler, repo: repo)
    expect(handler.invoked_correctly?).to be true
  end

  def create_duplicate_user
    create_valid_user
    subject.(username: 'valid name', handler: handler, repo: repo)
    expect(handler.invoked_correctly?).to be true
  end

  def create_missing_username_user
    subject.(username: '', handler: handler, repo: repo)
    expect(handler.invoked_correctly?).to be true
  end

  it 'meets the create user contract' do
    expect { handler.class.validate_contract }.to_not raise_error
  end

  it 'invokes the handler collaborator correctly' do
    create_valid_user
    create_duplicate_user
    create_missing_username_user
    expect(handler.all_behaviors_invoked?).to be true
  end

  it 'requires a username' do
    create_missing_username_user
    expect(handler.spy_validation_failed).to include(username: :required)
  end

  it 'requires usernames to be unique' do
    create_duplicate_user
    expect(handler.spy_validation_failed).to include(username: :unique)
  end

  it 'sends an id for the created user back to the handler' do
    create_valid_user
    expect(handler.spy_user_created).to be
  end
end
