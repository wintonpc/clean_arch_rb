module SpecHelpers
  class MakeASpyForContract
    def self.call(contract_module)
      klass = Class.new do
        include contract_module
        def initialize
          self.class.required_function_names.each do |fn|
            instance_variable_set("@#{fn.to_s}_invoked", 0)
            self.class.class_eval {
              attr_reader "spy_#{fn.to_s}".to_sym
              define_method fn.to_s do |*args|
                instance_variable_set("@spy_#{fn.to_s}", args)
                invoked_var = instance_variable_get("@#{fn.to_s}_invoked")
                invoked_var += 1
                instance_variable_set("@#{fn.to_s}_invoked", invoked_var)
              end
              define_method "#{fn.to_s}_worked" do
                if instance_variable_get("@#{fn.to_s}_invoked") == 1 && (self.class.required_function_names - [fn]).all? { |real_fn| instance_variable_get("@#{real_fn.to_s}_invoked") ==0 }
                  instance_variable_set("@#{fn.to_s}_behavior_worked", true)
                  true
                else
                  false
                end
              end
            }
            def invoked_correctly?
              result = self.class.required_function_names.any?{ |fn| send("#{fn.to_s}_worked") }
              self.class.required_function_names.map { |fn| instance_variable_set("@#{fn.to_s}_invoked", 0) }
              result
            end
            def all_behaviors_invoked?
              self.class.required_function_names.all? { |fn| instance_variable_get("@#{fn.to_s}_behavior_worked") }
            end
          end
        end
      end
      klass.new
    end
  end
end
