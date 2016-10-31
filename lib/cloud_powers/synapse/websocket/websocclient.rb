require 'websocket-eventmachine-client'

module Smash
  module CloudPowers
    module Synapse
      module WebSocClient
        include Smash::Helpers

        def create_websoc_client(opts = {})
          socket = opts[:socket]
          client_name = to_i_var(opts[:name] || 'default_client')
          Thread.new(socket) do
            EM.run do
              if socket.nil?
                socket = WebSocket::EventMachine::Client.connect(:uri => 'ws://' + opts[:host]  + ':' + opts[:port])
                instance_variable_set(client_name, socket)
              end

              open_callback = opts[:on_open] || Proc.new do
                puts "Connected"
              end
              socket.onopen &open_callback

              on_message_callback = opts[:on_message] || Proc.new do |msg, type|
                puts "Received message: #{msg}"
              end
              socket.onmessage &on_message_callback

              on_error_callback = opts[:on_error] || Proc.new do |error|
                puts "Error ==> #{error}"
              end
              socket.onerror &on_error_callback

              on_close_callback = opts[:on_close] || Proc.new do |code, reason|
                puts "Disconnected with status code: #{code}"
                puts "Disconnected with status message: #{reason}"
              end
              socket.onclose &on_close_callback
            end
          end
          socket
        end
      end
    end
  end
end
