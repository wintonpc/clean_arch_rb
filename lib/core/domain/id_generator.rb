require 'securerandom'

module Core
  class IdGenerator
    def generate
      SecureRandom.uuid
    end
  end
end
