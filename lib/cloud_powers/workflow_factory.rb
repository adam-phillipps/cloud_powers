require 'workflow'

module Smash
  module CloudPowers
    # The WorkflowFactory module provides you with a custom, embeddable workflow
    # for classes.  To do this, it takes a description of the workflow, in
    # the form of a <tt>Hash</tt> and injects it into the class' Singleton/Eigan
    # class.  It uses the +workflow+ gem to handle the workflow stuff for now
    # but after MVP, this will be a roll-our-own implementation, to cut down on
    # all dependencies possible.
    module WorkflowFactory
      # This is the method responsible for injecting the workflow on the instance
      # it is called on.  After this method is called on an instance of some class,
      # you can then access any of the described states as methods on that instance.
      #
      # Parameters
      # * description +Hash+ - Describe the workflow you want to use.  The format
      #   follows the actual Workflow Specification(s) from the gem that you would
      #   normally write onto the class like normal.
      #
      # * Example +description+ +Hash+
      # * * this description would give you a workflow that starts in the +new+
      #     state and when the <tt>#build!()</tt> method was called on the object
      #     that has this workflow, the state would transition into the +building+
      #     state.  The workflow would then listen for the <tt>run!()</tt> method
      #     call, which would progress the state to the +in_progress+ state.  Next,
      #     the workflow would listen for the <tt>post_results!()</tt> method
      #     call.  When someone or something calls it, the state will progress to
      #     the final state, +done+, from which no more workflow stuff will happen.
      #
      #     description = {
      #       workflow: {
      #         states: [
      #           { new: { event: :build, transitions_to: :building } },
      #           { building: { event: :run, transitions_to: :in_progress } },
      #           { in_progress: { event: :post_results, transitions_to: :done } },
      #           { done: nil }
      #         ]
      #       }
      #     }
      #
      # ##Returns
      # * +nil+
      #
      # ##Example
      # * build the workflow using the description from above
      #     class Job
      #       # code code code...
      #       def insert_my_workflow(description)
      #         class << build_workflow(description)
      #       end
      #     end
      #
      #   Which would yield this workflow, from the Workflow gem
      #
      #     class Job
      #       # all the commented lines below are what `WorkflowFactory#inject_workflow()`
      #       # did for you.  These lines don't need to actually be in your class.
      #
      #       # include Workflow
      #       #
      #       # workflow do
      #       #   state :new do
      #       #     event :build, :transitions_to => :building
      #       #   end
      #       #   state :building do
      #       #     event :run, :transitions_to => :in_progress
      #       #   end
      #       #   state :in_progress do
      #       #     event :post_results, :transitions_to => :done
      #       #   end
      #       #   state :done
      #       # end
      #     end
      #
      #     job = Job.new
      #     # => #<Job:0x007fdaba8956b0>
      #     job.done?
      #     # => NoMethodError
      #     job.insert_workflow(description)
      #     # => nil
      #     job.done?
      #     # => false
      #     job.current_state
      #     # => :building
      #
      # Notes
      # * TODO: There has got to be a better way, so if any of you have suggestions...
      #   The fact that the eval gets evaluated and invoked in the workflow gem
      #   is of little comfort, despite how nice the gem is.  Long story short,
      #   be comfortable with what you're doing.
      # * see the workflow gem docs and question me if you want some nice ways
      #   to really use this module. {workflow homepage}[https://github.com/geekq/workflow]
      def inject_workflow(description)
        description_string_builder = ['include Workflow', 'workflow do']
        description[:workflow][:states].each do |state|
          state.map do |name, state_description|
            if state_description.nil? # if this is a final state...
              description_string_builder << "state :#{name}"
            else # because it is not a final state, add event information too.
              description_string_builder.concat([
                "state :#{name} do",
                "event :#{state_description[:event]}, transitions_to: :#{state_description[:transitions_to]}",
                "end"
              ])
            end
          end
        end
        description_string_builder << "end\n"
        begin
          self.class.class_eval(description_string_builder.join("\n"))
          define_singleton_method(:has_workflow?) { true }
        rescue Exception => e
          define_singleton_method(:has_workflow?) { !!(puts e.backtrace) }
        end
      end
    end
  end
end
