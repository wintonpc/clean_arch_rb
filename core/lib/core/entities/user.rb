module Core
  module Entities
    class User
      attr_reader :username
      attr_accessor :id

      def initialize(username:)
        @username = username
      end
    end
  end
end
