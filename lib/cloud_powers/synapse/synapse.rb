require_relative 'queue'
require_relative 'pipe'

module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPowers::Synapse::Pipe
      include Smash::CloudPowers::Synapse::Queue
    end
  end
end
