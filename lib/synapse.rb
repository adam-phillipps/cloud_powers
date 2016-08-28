require_relative 'helper'
require_relative 'queue'
require_relative 'pipe'

module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPower::Helper
      include Smash::CloudPower::Pipe
      include Smash::CloudPower::Queue
      include Smash::CloudPower::SelfAwareness
    end
  end
end
