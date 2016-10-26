module Smash
  module BrainFunc
    module CerebrumFunctions
      def create_message(*args)
        merge_arguments(*args).to_json
      end

      def create_messages(n, *args)
        n.times { create_message(*args) }
      end

      def merge_arguments(*args)
        byebug
        args.inject({}) do |carry, msg_piece|
          formatted_piece = msg_piece.kind_of?(Hash) ? msg_piece : JSON.parse(msg_piece)
          carry.merge(formatted_piece)
        end
      end
    end
  end
end

# all cerebrum jobs will
# 1. create context messages for neurons
# 2. build that context for real
# 3. send sitreps about itself
# 4. send sitreps about its neurons
# 5. have the ability to have a workflow and all that
# 6.
