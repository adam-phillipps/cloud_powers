module Smash
  class Workflow
    attr_accessor :states

    def initialize(states = nil)
      @states = states || [:backlog, :wip, :done]
      @previous = @states.first
    end

    def current
      @states.first
    end

    def last
      @states.last
    end

    def next
      @states[1]
    end

    def next!
      @pevious = @states.shift
      @states.first
    end
  end
end
