require_relative '../helper'
require_relative 'pipe'
require_relative 'queue'

module Smash
  module CloudPowers
    extend Helper

    module Synapse
      include Pipe
      include Queue
    end
  end
end
