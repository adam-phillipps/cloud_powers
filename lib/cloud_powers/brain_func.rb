require 'cloud_powers/brain_func/context_capable'
require 'cloud_powers/brain_func/delegator'
require 'cloud_powers/brain_func/self_awareness'
require 'cloud_powers/brain_func/workflow_factory'

module Smash
  # BrainFunc gives projects the ability to use CloudPowers and the Helpers
  # modules to run any code in any context, dynamically.
  module BrainFunc
    # Manage the resources needed to complete a Job
    include Smash::BrainFunc::ContextCapable
    # Dynamic Resource creation and delegation
    include Smash::BrainFunc::Delegator
    # Gathers data about an instance, itself
    include Smash::BrainFunc::SelfAwareness
    # Dynamically Builds and loads a Workflow into a class at runtime
    include Smash::BrainFunc::WorkflowFactory
  end
end
