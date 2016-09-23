require 'uri'
require_relative '../helper'

module Smash
  module CloudPowers
    module Synapse
      include Smash::CloudPowers::Helper

      module Queue
        Board = Struct.new(:set_name, :set_address, :workflow) do
          include Smash::CloudPowers::Helper
          def i_var
            "@#{name}"
          end

          def address
            set_address ||
              env(name) ||
              "https://sqs.us-west-2.amazonaws.com/088617881078/#{name}"
          end

          def name
            set_name || address.split('/').last
          end

          def next_board
            workflow.next
          end
        end # end Board
        #############################################

        def board_name(url)
          url.to_s.split('/').last
        end

        # def board_name(url)
        #   # TODO: figure out a way to not have this and :name in Board
        #   # gets the name from the url
        #   if url =~ URI.regexp
        #     url = URI.parse(url)
        #     url.path.split('/').last.split('_').last
        #   else
        #     env(url)
        #   end
        # end

        def create_queue(name)
          sqs.create_queue(queue_name: to_camel(name))
        end

        def delete_queue_message(queue, opts = {})
          poll(queue, opts) do |msg, stats|
            poller(queue).delete_message(msg)
            throw :stop_polling
          end
        end

        def get_count(board)
          sqs.get_queue_attributes(
            queue_url: board_name(board),
            attribute_names: ['ApproximateNumberOfMessages']
          ).attributes['ApproximateNumberOfMessages'].to_f
        end

        # Params: board<string>
        # returns a message and deletes it from its origin
        def pluck_message(board)
          poll(board) do |msg, poller|
            poller.delete_message(msg)
            return msg
          end
        end

        def poll(board, opts = {})
          this_poller = poller(board)
          this_poller.poll(opts) do |msg|
            yield msg, this_poller if block_given?
          end
        end

        def poller(board_name)
          board = Board.new(board_name)

          unless instance_variable_defined?(board.i_var)
            instance_variable_set(
              board.i_var,
              Aws::SQS::QueuePoller.new(board.address)
            )
          end
          instance_variable_get(board.i_var)
        end

        def queue_exists?(name)
          sqs.list_queues(queue_name_prefix: name)
        end

        def send_queue_message(message, *board_info)
          board = board_info.first.kind_of?(Board) ? board_info.first : Board.new(*board_info)
          message = message.to_json unless message.kind_of? String
          sqs.send_message(
            queue_url: board.address,
            message_body: message
          )
        end

        def sqs
          @sqs ||= Aws::SQS::Client.new(credentials: Auth.creds)
        end
      end
    end
  end
end
