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
        # encrypt a string
        #
        # arg: the string to encrypt
        # returns: the encrypted string
        :validation_failed,
        # decrypts a string
        #
        # arg: the string to decrypt
        # returns: the decrypted string
        :user_created,          # (encrpyted string)
      ]
    end

    def validate_contract
      InstanceMethodValidator.new(required_function_names).validate(self)
    end
  end
end
