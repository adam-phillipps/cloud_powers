module Smash
  module BrainFunc
    module CerebrumFunctions
      # Creates a JSON structure from all the given arguments
      # When arguments are structured correctly, they are merged together
      # into a larger +Hash+ then turned into +JSON+ and returned
      #
      # Parameters
      # * +JSON+|+Hash+|+Object+ - accepts <tt>0..n</tt> arguments
      # * structure of the arguments works best when given this way
      #     { config_a: { stuff }, config_b: { stuff } }
      #
      # Example
      #   context = "{\"context\": { \"task\": [\"test\""], queue: [:queues], ... } }
      #   workflow = { workflow: { states: [...] }
      #   other_stuff = { '' => '' } # and so on ...
      #
      #   create_message(context, workflow, other_stuff)
      #   # => '{"context":{"task":["test"],"queue":[":queues"], ... },
      #          "workflow":" {"states":[...]},
      #          "other_stuff":{"":""}
      #        }'
      #
      #
      def create_message(*args)
        return { message: args }.to_json unless valid_entrypoint_message_format?(*args)
        merge_arguments(*args).to_json
      end

      # Creates an +Array+ of messages
      #
      # Parameters
      # * +n+ +Number+ - the number of messages to create
      # * +JSON+|+Hash+|+Object+ - accepts <tt>0..n</tt> arguments
      #
      # Returns
      # +Array+
      #
      # Notes
      # * See <tt>create_message()</tt>
      def create_messages(n, *args)
        n.times { create_message(*args) }
      end

      # Merge all of the +JSON+ and +Hash+ arguments together
      def merge_arguments(*args)
        args.inject({}) do |carry, msg_piece|
          formatted_piece = msg_piece.kind_of?(Hash) ? msg_piece : JSON.parse(msg_piece)
          carry.merge(formatted_piece)
        end
      end

      # Just some overridable message body that's going to get a rework ASAP
      def sitrep_message(opts = {})
        # TODO: find better implementation of merging nested hashes
        # this should be fixed with ::Helper#update_message_body
        extra_info = {}
        if opts.kind_of?(Hash) && opts[:extraInfo]
          custom_info = opts.delete(:extraInfo)
          extra_info = { 'taskRunTime' => task_run_time }.merge(custom_info)
        else
          opts = {}
        end

        sitrep_alterations = {
          type: 'SitRep',
          content: to_pascal(state),
          extraInfo: extra_info
        }.merge(opts)
        update_message_body(sitrep_alterations)
      end

      def state
        begin
          current_state.name
        rescue NoMethodError => e
          :unk
        end
      end

      # Time should be set already, early in your class but if it wasn't, the
      # clock starts now
      #
      # Returns
      # +Integer+
      def task_run_time
        @start_time ||= Time.now.to_i
        Time.now.to_i - @start_time
      end

      # Finds out if the arguments are valid for creating an entrypoint message
      # If the arguments all can pass any of these tests, +true+ is returned.  If
      # any argument fails one test, +false+ is returned:
      # 1. Hash?
      # 2. valid JSON?
      #
      # Parameters
      # * +JSON+|+Hash+
      #
      # Returns
      # * +Boolean+
      def valid_entrypoint_message_format?(*args)
        begin
          # This will iterate through the arguments and, one by one, ask
          # "Is this a hash?  If so, we're good.  If not, try to find out if
          # it's parsable JSON.  If it's not parsable as JSON, an exception will
          # be thrown and caught, then +false+ returned"
          !!args.each do |info|
            info.kind_of?(Hash) ? true : JSON.parse(info)
          end
        rescue JSON::ParserError
          false
        end
      end
    end
  end
end

