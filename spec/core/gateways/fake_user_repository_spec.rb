require 'rspec'
require 'core/gateways/user/fake_user_repository'
require 'core/gateways/user_repository_contract'
user_repository_contract(FakeUserRepository)
