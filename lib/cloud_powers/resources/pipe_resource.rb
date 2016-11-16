module Smash
  module CloudPowers
    module Synapse
      module Pipe
        class PipeResource
          include Smash::CloudPowers::Synapse::Pipe

          def initialize(opts)
          end

          def self.build(opts)
            resource = new(opts)
            resource.attr_map!(opts)
          end

          def self.create!(opts)
            self.build(opts).save!
          end

          def save!
            self
          end

          def update(key, value)
          end
        end
      end
    end
  end
end

