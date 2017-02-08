require 'spec_helper'

RSpec.describe Core do
  it 'has a version number' do
    expect(Core::VERSION).not_to be nil
  end
end
