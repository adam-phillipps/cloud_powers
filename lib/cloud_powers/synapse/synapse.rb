# require 'helper'
# require 'queue'
# require 'pipe'

module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPowers::Synapse::Pipe
      include Smash::CloudPowers::Synapse::Queue
    end
  end
end
