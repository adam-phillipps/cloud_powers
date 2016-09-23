require 'cloud_powers/auth'
require 'cloud_powers/aws_resources'
require 'cloud_powers/delegator'
require 'cloud_powers/helper'
require 'cloud_powers/self_awareness'
require 'cloud_powers/storage'
require 'cloud_powers/version'
require 'cloud_powers/workflow'

module Smash
  module CloudPowers
    extend Smash::CloudPowers::Auth
    extend Smash::CloudPowers::Delegator
    include Smash::CloudPowers::AwsResources
    include Smash::CloudPowers::Helper
    include Smash::CloudPowers::SelfAwareness
    include Smash::CloudPowers::Storage
    include Smash::CloudPowers::Synapse
  end
end
