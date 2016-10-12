require 'cloud_powers/auth'
require 'cloud_powers/aws_resources'
require 'cloud_powers/context'
require 'cloud_powers/delegator'
require 'cloud_powers/helper'
require 'cloud_powers/node'
require 'cloud_powers/self_awareness'
require 'cloud_powers/storage'
require 'cloud_powers/version'
require 'cloud_powers/workflow'

# The Smash module allows us to use CloudPowers under a shared name space with other projects.
module Smash
  # The CloudPowers module contains all the other modules and classes that creates the <i>CloudPowers</i> gem.
  module CloudPowers
    # Authentication mixin
    extend Smash::CloudPowers::Auth
    # Dynamic Resource creation and delegation
    extend Smash::CloudPowers::Delegator
    # Aws clients, like EC2 and S3
    include Smash::CloudPowers::AwsResources
    # Various helper methods
    include Smash::CloudPowers::Helper
    # Gathers data about an instance, itself
    include Smash::CloudPowers::SelfAwareness
    # Store files
    include Smash::CloudPowers::Storage
    # Communication modules
    include Smash::CloudPowers::Synapse
    # CRUD on Nodes, which are individual instances
    include Smash::CloudPowers::Node
  end
end
