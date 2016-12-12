require 'cloud_powers/synapse/web_soc/soc_client'
require 'cloud_powers/synapse/web_soc/soc_server'

module Smash
  module CloudPowers
    module Synapse
      module WebSoc
        include Smash::CloudPowers::Synapse::WebSoc::SocClient
        include Smash::CloudPowers::Synapse::WebSoc::SocServer
      end
    end
  end
end
