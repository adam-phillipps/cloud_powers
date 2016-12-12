require 'cloud_powers/auth'
require 'cloud_powers/aws_resources'
require 'cloud_powers/helpers'
require 'cloud_powers/node'
require 'cloud_powers/resource'
require 'cloud_powers/storage'
require 'cloud_powers/version'
require 'cloud_powers/synapse/synapse'

# The Smash module allows us to use CloudPowers under a shared name space with other projects.
module Smash
  # The CloudPowers module contains all the other modules and classes that creates the <i>CloudPowers</i> gem.
  module CloudPowers
    # Authentication mixin
    extend Smash::CloudPowers::Auth
    # Aws clients, like EC2 and S3
    include Smash::CloudPowers::AwsResources
    # Store files
    include Smash::CloudPowers::Storage
    # Communication modules
    include Smash::CloudPowers::Synapse
    # CRUD on Nodes, which are individual instances
    include Smash::CloudPowers::Node
  end
end
