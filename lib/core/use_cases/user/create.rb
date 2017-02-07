require 'core/entities/user'

module Core
  module UseCases
    module User
      class Create
        def self.execute(username:, handler:, repo:)
          if username.empty?
            handler.validation_failed(username: :required)
          elsif repo.find_by_username(username)
            handler.validation_failed(username: :unique)
          end
          user = Core::Entities::User.new(username: username)
          repo.save(user)
          handler.user_created(user.id)
        end
      end
    end
  end
end
