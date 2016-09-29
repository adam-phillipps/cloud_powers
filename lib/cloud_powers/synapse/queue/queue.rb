require 'uri'
require_relative 'board'

module Smash
  module CloudPowers
    module Synapse
      module Queue
        include Smash::CloudPowers::Helper
        include Smash::CloudPowers::AwsResources

        def board_name(url)
          url.to_s.split('/').last
        end

        def create_queue!(name)
          begin
            Board.new(to_camel(name)).create_queue!
          rescue Aws::SQS::Errors::QueueDeletedRecently => e
            sleep 5
            retry
          end
        end

        def build_queue(name)
          Board.new(to_camel(name))
        end

        def delete_queue_message(queue, opts = {})
          poll(queue, opts) do |msg, stats|
            poller(queue).delete_message(msg)
            throw :stop_polling
          end
        end

        def get_queue_message_count(board_url)
          sqs.get_queue_attributes(
            queue_url: board_url,
            attribute_names: ['ApproximateNumberOfMessages']
          ).attributes['ApproximateNumberOfMessages'].to_f
        end

        # @params: board<String|symbol>: The name of the board
        # @returns a message and deletes it from its origin
        def pluck_queue_message(board)
          poll(board) do |msg, poller|
            poller.delete_message(msg)
            return valid_json?(msg.body) ? JSON.parse(msg.body) : msg.body
          end
        end

        def poll(board, opts = {})
          this_poller = queue_poller(board)
          results = nil
          this_poller.poll(opts) do |msg|
            results = yield msg, this_poller if block_given?
            this_poller.delete_message(msg)
            throw :stop_polling
          end
          results
        end

        def queue_poller(board_name)
          board = Board.new(board_name)

          unless instance_variable_defined?(board.i_var)
            instance_variable_set(
              board.i_var,
              board
            )
          end
          instance_variable_get(board.i_var).poller
        end

        def queue_exists?(name)
          !sqs.list_queues(queue_name_prefix: name).queue_urls.empty?
        end

        def queue_search(name)
          sqs.list_queues(queue_name_prefix: name).queue_urls
        end

        def send_queue_message(address, message)
          sqs.send_message(
            queue_url: address,
            message_body: message
          )
        end
      end
    end
  end
end
