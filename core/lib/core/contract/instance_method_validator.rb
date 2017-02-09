class InstanceMethodValidator
  attr_accessor :required_function_names

  def initialize(required_function_names)
    @required_function_names = required_function_names
  end

  # klass can be either a class name or a class object.
  def validate(klass)
    if klass.is_a? String
      klass = Kernel.const_get(klass)
    end

    missing_function_names = required_function_names - klass.public_instance_methods

    unless missing_function_names.empty?
      raise RuntimeError.new("Class #{klass} is missing the following required functions: #{missing_function_names.join(", ")}.")
    end

  end

end
