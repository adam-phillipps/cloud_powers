require 'websocket-eventmachine-server'
module Smash
  module CloudPowers
    module Synapse
      module WebSocServer
        def create_websoc_server(opts = {})
          channel = opts[:channel] || EM::Channel.new
          Thread.new do
            EM.run do
              WebSocket::EventMachine::Server.start(:host => opts[:host], :port => opts[:port]) do |ws|
                sid = nil

                open_callback = opts[:on_open] || Proc.new do
                  puts "Client connected"
                  sid = channel.subscribe { |msg| ws.send msg }
                end
                ws.onopen &open_callback

                on_message_callback = opts[:on_message] || Proc.new do |msg, type|
                  @current_websocket_message = msg
                end
                ws.onmessage &on_message_callback

                on_error_callback = opts[:on_error] || Proc.new do |error|
                  puts "Error occured: #{error}"
                end
                ws.onerror &on_error_callback

                on_close_callback = opts[:on_close] || Proc.new do
                  puts "Client disconnected"
                  channel.unsubscribe(sid) unless channel.nil?
                end
                ws.onclose &on_close_callback
              end
            end
          end
          channel
        end

        def broadcast(channel, msg)
          channel.push msg
        end
      end
    end
  end
end