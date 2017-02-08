require 'core/entities/user'
require 'core/util/strict_case_matcher'
require 'core/use_cases/user/create'

module Core
  module UseCases
    module User
      class CreateMany
        Success = Struct.new(:created_user_ids)
        Failure = Struct.new(:validation_errors)

        Creator = Create.new do |r|
          r.when matches { Create::Success }
          r.when matches { Create::Failure }
        end

        def execute(usernames:, env:, repo:, &block)
          results = usernames.map do |username|
            Creator.execute(username: username, env: env, repo: repo)
          end
          StrictCaseMatcher.match(aggregate_result(results), &block)
        end

        private

        def aggregate_result(results)
          successes, failures = results.partition { |r| r.is_a?(Success) }
          if failures.any?
            Failure.new(failures.flat_map(&:validation_errors))
          else
            Success.new(successes.map(&:created_user_id))
          end
        end
      end
    end
  end
end
