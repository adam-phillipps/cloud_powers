require_relative 'helper'
require_relative 'queue'
require_relative 'pipe'

module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPowers::Helper
      include Smash::CloudPowers::Pipe
      include Smash::CloudPowers::Queue
      include Smash::CloudPowers::SelfAwareness
    end
  end
end
