require 'core/contract/instance_method_validator'
module UserCreateContract
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods

    def required_function_names
      [
        # The purpose of this function is self-evident, but in other
        # cases the methods would benefit from some explanation
        # that would be helpful to authors of new implementations,
        # such as defining correct behavior, format and data type
        # of arguments and return values.
        #
        # Creating a user fails for a validation reason
        #
        # arg: A hash representing the validation errors, the key
        # is the field that was invalid, the value is a symbol of the reason
        # returns: Is ignored by the use case
        :validation_failed,
        # decrypts a string
        #
        # arg: The ID of the created user
        # returns: Is ignored by the use case
        :user_created
      ]
    end

    def validate_contract
      InstanceMethodValidator.new(required_function_names).validate(self)
    end
  end
end
