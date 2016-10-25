module Smash
  module BrainFunc
    module CerebrumFunctions
      def create_message(*args)
        byebug
        args.map(&:to_json)
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
