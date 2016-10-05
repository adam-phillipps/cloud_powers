require 'websocket-eventmachine-client'

module Smash
  module CloudPowers
    module Synapse
      module WebSocClient
        def create_websoc_client( host, port )
          EM.run do

            ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://' + host  + ':' + port)

            ws.onopen do
              puts "Connected"
            end

            ws.onmessage do |msg, type|
              puts "Received message: #{msg}"
            end
        
            ws.onerror do |error|
              puts "Error ==> #{error}"
            end

            ws.onclose do |code, reason|
              puts "Disconnected with status code: #{code}"
              puts "Disconnected with status message: #{reason}"
            end

            EventMachine.next_tick do
              ws.send "Hello Server!"
            end
          end
        end
      end
    end
  end
end
