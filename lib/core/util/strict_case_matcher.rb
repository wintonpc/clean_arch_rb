require 'destructure'
require 'binding_of_caller'

module Core
  class StrictCaseMatcher
    def self.match(value, &block)
      matcher = StrictCaseMatcher.new
      block.call(matcher)
      matcher.cases.each do |pattern, handler|
        if m = DMatch.match(pattern, value)
          return handler ? handler.call(m.to_openstruct) : nil
        end
      end
      raise "Failed to match: #{value}"
    end

    def when(pattern_proc, &handler)
      sexp = pattern_proc.to_sexp(strip_enclosure: true, ignore_nested: true)
      b = binding.of_caller(1)
      pattern = Destructure::SexpTransformer.transform(sexp, b)
      cases << [pattern, handler]
    end

    alias_method :assert, :when

    def cases
      @cases ||= []
    end
  end
end

module Kernel
  def matches(&block)
    Proc.new(&block)
  end
end
