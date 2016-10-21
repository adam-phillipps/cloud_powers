require 'workflow'

module Smash
  module CloudPowers
    module WorkflowFactory
      include Workflow

      def build_workflow(description)
        byebug
        description[:workflow][:states].each do |state, event_info|
          event_block = lambda { Workflow.event event_info }
          self.instance_eval(state.to_sym) event_block
        end
      end
    end
  end
end

# state(:new) { event(:build, :transitions_to => :building) }
# description[:workflow][:states].each do |state|

# end
# description = {
#   workflow: {
#     states: [
#       { new: { event: :build, transitions_to: :building } },
#       { building: { event: :run, transitions_to: :in_progress } },
#       { in_progress: { event: :post_results, transitions_to: :done } },
#       { done: nil }
#     ]
#   }
# }

# workflow do
#   state :new do
#     event :add_workflow, :transitions_to => :adding_workflow
#   end
#   state :adding_workflow do
#     event :run, :transitions_to => :in_progress
#   end
#   state :being_reviewed do
#     event :accept, :transitions_to => :accepted
#     event :reject, :transitions_to => :rejected
#   end
#   state :accepted
#   state :rejected
# end
