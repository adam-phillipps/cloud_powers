require 'websocket-eventmachine-client'

module Smash
  module CloudPowers
    module Synapse
      module WebSocClient

        def create_websoc_client(opts = {})

          EM.run do
            ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://' + opts[:host]  + ':' + opts[:port])
            add_to_clients(opts[:name], ws)

            open_callback = opts[:on_open] || Proc.new do
              puts "Connected"
            end

            ws.onopen &open_callback

            on_message_callback = opts[:on_message] || Proc.new do |msg, type|
              puts "Received message: #{msg}"
            end

            ws.onmessage &on_message_callback

            on_error_callback = opts[:on_error] || Proc.new do |error|
              puts "Error ==> #{error}"
            end

            ws.onerror &on_error_callback

            on_close_callback = opts[:on_close] || Proc.new do |was_clean, code, reason|
              puts "Disconnected with status code: #{code}"
              puts "Disconnected with status message: #{reason}"
            end

            ws.onclose &on_close_callback
          end
        end

        def add_to_clients(name, client)
          begin
            @websoc_clients[name] = client
          rescue NoMethodError => e
            puts e.backtrace
            puts "no client hash is available"
          end
          @websoc_clients
        end
      end
    end
  end
end


