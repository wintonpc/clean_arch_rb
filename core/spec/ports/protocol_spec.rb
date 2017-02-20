require 'rspec'
require 'ports'

module Predicates
  refine Module do
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
end

# a protocol...
protocol :ui do
  # ... specifies two roles, each having an interface
  role :server do |s|
    s.create_user(string) # method contracts
  end

  role :client do |c|
    c.validation_failed(hash)
    c.user_created(hash)
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

protocol :repo do
  role :repo do |r|
    r.save(user)
  end

  role :client do |c|
    c.save_succeeded
    c.save_failed
  end

  interactions do
    seq do
      repo.save
      one_of do # constructs like `one_of` help concisely describe execution path branching
        client.save_succeeded
        client.save_failed
      end
    end
  end
end

# A port joins two adapters which implement complimentary roles of a given protocol.
# The port delegates calls to the appropriate adapter, and, at test time,
# is responsible for
# - verifying interactions are valid
# - tracking interaction coverage (like code coverage)
class Port
  attr_accessor :protocol, :adapters
end

class Ascent
  implement :ui_port, :ui, :server # defines `ui_port` attribute, which is a :ui Port bound to an AscentUIAdapter
  implement :repo_port, :repo, :client # defines `repo_port` attribute, which is a :repo Port bound to an AscentRepoAdapter
end

class AscentDomainAdapter
  def create_user(name)
    # ...
  end
end

class AscentRepoAdapter
  def save_succeeded
    # ...
  end
  def save_failed
    # ...
  end
end

class RailsAdapter
  def validation_failed(info)
    # ...
  end
  def user_created(id)
    # ...
  end
end

describe 'My behaviour' do
  it 'should do something' do
    ascent = Ascent.new
    rails = RailsAdapter.new
    ascent.ascent_port.bind(rails)
  end
end
