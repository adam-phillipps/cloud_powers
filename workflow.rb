module Smash
  class Workflow
    attr_accessor :all_states, :first, :last, :previous, :states

    def initialize(statez = nil)
      # TODO: figure out wtf here with the i-vars changing each other
      @all_states = statez || [:backlog, :wip, :done]
      @states = statez || [:backlog, :wip, :done]
      @first = (statez || [:backlog, :wip, :done]).first
      @last = (statez || [:backlog, :wip, :done]).last
      @previous = [(statez || [:backlog, :wip, :done]).first]
    end

    def current
      @states.first
    end

    def finished?
      @states.first == @states.last
    end

    def next
      finished ? @states.first : @states[1]
    end

    def next!
      return if finished?
      @previous << @states.shift
      @states.first
    end
  end
end
