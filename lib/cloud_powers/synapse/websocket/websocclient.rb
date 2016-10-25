require 'websocket-eventmachine-client'

module Smash
  module CloudPowers
    module Synapse
      module WebSocClient

        def create_websoc_client(opts = {})

          EM.run do

            @ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://' + opts[:host]  + ':' + opts[:port])

            open_callback = opts[:on_open] || Proc.new do
              puts "Connected"
            end

            @ws.onopen &open_callback

            on_message_callback = opts[:on_message] || Proc.new do |msg, type|
              puts "Received message: #{msg}"
            end

            @ws.onmessage &on_message_callback

            on_error_callback = opts[:on_error] || Proc.new do |error|
              puts "Error ==> #{error}"
            end

            @ws.onerror &on_error_callback

            on_close_callback = opts[:on_close] || Proc.new do |code, reason|
              puts "Disconnected with status code: #{code}"
              puts "Disconnected with status message: #{reason}"
            end

            @ws.onclose &on_close_callback

          end

        end
      end
    end
  end
end
