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
      raise MatchFailedError, "Failed to match: #{value}"
    end

    def when(pattern_proc, &handler)
      sexp = pattern_proc.to_sexp(strip_enclosure: true, ignore_nested: true)
      b = binding.of_caller(1)
      pattern = Destructure::SexpTransformer.transform(sexp, b)
      cases << [pattern, handler]
    end

    def self.assert_cases_are_handled(handler, cases)
      cases.each do |c|
        begin
          match(c, &handler)
        rescue MatchFailedError
          raise UnhandledCaseError, "You need to handle this case: #{c}"
        end
      end
    end

    alias_method :assert, :when

    def cases
      @cases ||= []
    end

    class MatchFailedError < RuntimeError
    end
    class UnhandledCaseError < RuntimeError
    end
  end
end

module Kernel
  def matches(&block)
    Proc.new(&block)
  end
end
