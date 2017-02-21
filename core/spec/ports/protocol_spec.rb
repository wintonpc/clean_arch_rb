require 'rspec'
require 'ports'

# Objectives
# - create framework for ports & adapters pattern
# - symmetry between interacting adapters
# - model method signature
#   - parameters types, predicates
# - model a variety of interaction styles
#   - sync vs. async
#   - request/response
#   - more complex conversations
#     - state machine
#       - loops
#       - branches
# - test-time verification
#   - all methods implemented
#   - all methods called
# - be modular: group code and definitions however makes sense, independent of other concernes
# - performance
#   - transparently drop out of the way in production
#     try to avoid even delegation

module CommonPredicates
  def string
    proc { |x| x.is_a?(String) }
  end
  def id
    proc { |x| x =~ /[0-9a-f]{24}/ }
  end
  def hash
    proc { |x| x.is_a?(hash) }
  end
  def user
    proc { true } # TODO
  end
end

# protocol :repo do
#   role :repo do |r|
#     r.save(user)
#   end
#
#   role :client do |c|
#     c.save_succeeded
#     c.save_failed
#   end
#
#   interactions do
#     seq do
#       repo.save
#       one_of do # constructs like `one_of` help concisely describe execution path branching
#         client.save_succeeded
#         client.save_failed
#       end
#     end
#   end
# end


# a protocol...
protocol :create_user do
  # ... specifies two roles, each having an interface
  role :interactor do |i|
    i.create_user(name: string) # method contracts
  end

  role :client do |c|
    c.user_created(id: id)
    c.validation_failed(error: hash)
  end

  # ... and valid sequences of interaction between the roles
  interactions do
    seq do
      server.create_user
      client.validation_failed
    end
    seq do
      server.create_user
      client.user_created(id)
    end
  end
end

# creates a module ...
module Protocols
  module CreateUser
    module Interactor
      def create_user(name)
        raise 'not implemented'
      end
    end
    module Client
      def user_created(id)
        raise 'not implemented'
      end
      def validation_failed(error)
        raise 'not implemented'
      end
    end
  end
end

module CreateUser
  # we specify which protocol role we interact with
  # and necessarily occupy the opposite role.
  interacts_with client: Protocols::CreateUser::Client
  #              ^^^^^^ the attribute name to use for interaction

  # TBD: interacts_with repo: Protocols::Repo::Gateway

  # we must implement the 'interactor' role...
  def create_user(name)
    if name.empty?
      client.validation_failed(username: :required)
    elsif repo.find_by_username(username)
      client.validation_failed(username: :unique)
    else
      user = Core::Entities::User.new(username: username)
      repo.save(user)
      client.user_created(user.id)
    end
  end
end

module Ascent
  # adapters can be defined in the same module or separate modules.
  # adapters can be brought together into a single module for convenience.
  include CreateUser
end

module RailsCreateUser
  interacts_with interactor: Protocols::CreateUser::Interactor

  def user_created(id)
    render 'success'
  end

  def validation_failed(error)
    render 'failure'
  end
end

module RailsAdapter
  include RailsCreateUser
end

# A port joins two adapters which implement complimentary roles of a given protocol.
# The port delegates calls to the appropriate adapter,
# and, at test time, is responsible for
# - verifying interactions are valid
# - tracking interaction coverage (like code coverage)
class Port
  attr_accessor :protocol, :adapters
end

describe CreateUser do
  let(:subject) { instance_of(CreateUser) }
  let(:rails) { spy(RailsCreateUser) }
  let(:port) { Port.connect(create_user, rails) }

  it 'should do something' do
    port.create_user('valid name')
    expect(port).to see_interaction {
      server.create_user('valid name')
      client.user_created
    }
  end
end
