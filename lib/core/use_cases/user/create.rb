require 'core/entities/user'
require 'core/util/strict_case_matcher'

module Core
  module UseCases
    module User
      class Create
        Success = Struct.new(:created_user_id)
        Failure = Struct.new(:validation_errors)

        def self.execute(username:, env:, repo:, &block)
          result =
            if username.empty?
              validation_failed(username: :required)
            elsif repo.find_by_username(username)
              validation_failed(username: :unique)
            else
              user = Core::Entities::User.new(username: username)
              repo.save(user, env: env)
              user_created(user.id)
            end
          StrictCaseMatcher.match(result, &block)
        end

        private

        def self.validation_failed(errors)
          Failure.new(errors)
        end

        def self.user_created(user_id)
          Success.new(user_id)
        end
      end
    end
  end
end
