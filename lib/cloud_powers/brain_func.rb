require 'cloud_powers/brain_func/context'
require 'cloud_powers/brain_func/delegator'
require 'cloud_powers/brain_func/self_awareness'
require 'cloud_powers/brain_func/workflow_factory'

module Smash
  module BrainFunc
    # Dynamic Resource creation and delegation
    include Smash::BrainFunc::Delegator
    # Gathers data about an instance, itself
    include Smash::BrainFunc::SelfAwareness
    # Dynamically Builds and loads a Workflow into a class at runtime
    include Smash::BrainFunc::WorkflowFactory
  end
end
