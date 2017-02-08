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
          else
            # TODO: This code if pushed outside the else only breaks unit tests because of us checking that the created should not be called
            # Can we do better?
            # What do we about errors from the repository? One thought is to apply the use case approach to the repository.
            # What do we do about random exceptions? We really don't want to raise any as who knows what exceptions a repository may contain
            # It could be active record exceptions underneath or mongoid or any other database driver! The list ends up being endless
            # For this reason I suspect it's better to explore "turtles all the way down" if you will.
            user = Core::Entities::User.new(username: username)
            repo.save(user)
            handler.user_created(user.id)
          end
        end
      end
    end
  end
end
