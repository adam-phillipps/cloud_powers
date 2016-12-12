require 'cloud_powers/resource'

module Smash
  module CloudPowers
    module Synapse
      module Broadcast
        class Channel < Smash::CloudPowers::Resource

          attr_accessor :sns

          def initialize(name:, client: sns, **config)
            @sns = client
            super
          end

          # Prefers the given arn but it can make a best guess if none is given
          #
          # Returns
          # arn +String+ - arn for this resource
          def arn
            @remote_id || "arn:aws:sns:#{zfind(:region)}:#{zfind(:accound_number)}:#{name}"
          end

          def remote_id
            @remote_id || arn
          end

          # Prefers the given name but it can parse the arn to find one
          #
          # Returns
          # name +String+ - name for this resource
          def name
            @name || set_arn.split(':').last
          end

          def create_resource
            @response = sns.create_topic(name: name)
            self
          end
        end
      end
    end
  end
end
