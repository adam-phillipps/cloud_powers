require 'uri'
require_relative 'board'

module Smash
  module CloudPowers
    module Queue
      def build_board(name)
        i_var = "@#{name}"
        if instance_variable_defined? i_var
          instance_variable_get i_var
        else
          board(name)
        end
      end

      def board(name)
        Board = Struct.new(:name) do
          def address
            env("#{name.upcase}_QUEUE_ADDRESS")
          end
          # this is a state machine, these are its states and they are strictly
          # enforced, yo.  Other methods should be refactored before this one.
          def next_board
            name == 'backlog' ? 'wip' : 'finished'
          end
        end

        Board.new(name)
      end

      def board_name(url)
        url = URI.parse(url)
        url.path.split('/').last.split('_').first
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

      def poll(board, opts = {})
        poller(board).poll(opts) do |msg|
          yield msg if block_given?
        end
      end

      # @returns:
      # a QueuePoller for the given board name
      def poller(board)
        name = "@#{board}"

        unless instance_variable_defined?(name)
          instance_variable_set(
            name,
            Aws::SQS::QueuePoller.new(board_address(board))
          )
        end

        instance_variable_get(name)
      end

      def send_message(board, message)
        sqs.send_message(
          queue_url: env(board)
          message_body: message
        )
      end

      def sqs
        @sqs ||= Aws::SQS::Client.new(credentials: creds)
      end
    end
  end
end
