require 'websocket-eventmachine-server'

module Smash
  module CloudPowers
    module Synapse
      module WebSocServer
        def create_websoc_server( host, port )
          @channel = EM::Channel.new
          Thread.new do
            EM.run do
              WebSocket::EventMachine::Server.start(:host => host, :port => port) do |ws|
                sid = nil

                ws.onopen do
                  puts "Client connected"
                  sid = @channel.subscribe { |msg| ws.send msg }
                end

                ws.onmessage do |msg, type|
                  puts "Received message: #{msg}"
                  @channel.push "<#{sid}>: #{msg}"
                end

                ws.onerror do |error|
                  puts "Error occured: #{error}"
                end

                ws.onclose do
                  puts "Client disconnected"
                  @channel.unsubscribe(sid) unless @channel.nil?
                end
              end
            end
          end
        end

        def send( msg )
          @channel.push "#{msg}" unless @channel.nil?
        end
      end
    end
  end
end
