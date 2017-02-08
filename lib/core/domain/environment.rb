require 'core/domain/id_generator'

module Core
  Environment = Struct.new(:id_generator)
end
