require 'cloud_powers'

module Smash
  module BrainFunc
    module CerebrumFunctions
      include Smash::CloudPowers::Helper
      # This method uses the Smash namespace to find all the resources that it
      # has.  It does this because those are the only kinds of resources we can
      # reliably produce, dynamically.  It moves through the given context to
      # match the keys with the type of resource.  It then matches the parameters
      # it has in the configuration array (the value in the key/pair <tt>{ resource: [config(s)] }</tt>)
      # and attempts to set the appropriate params or build the necessary objects
      # and/or resources in the cloud.
      #
      # Parameters
      # * +context+ <tt>Smash::Context</tt>|+Hash+ - A <tt>smash::Context</tt>
      #   can be used.  If a +Hash+ is given, it should be a
      #   <tt>Smash::Context.to_h</tt>-styled +Hash+
      #
      # Returns
      # * TODO: +nil+ # biunno...probably reuturn something?  maybe true?  but then
      #   false isn't a good thing to return if some fail but some succeed.
      def build_context(context)
        raise NotImplimentedError.new '#build_context() not implimented. ' +
          "called from: #{caller.join("\n")}"
      end

      def verify_context_built(context)
        raise NotImplimentedError.new '#verify_context_built() not implimented. ' +
          "called from: #{caller.join("\n")}"
      end

      def self.create(id, msg)
        job = new(id, msg)
        job.set_context(msg)
        job.set_workflow(msg)
        job
      end

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

      def set_context(context)

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
        current_state.name rescue :unk
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
          args.each do |info|
            !!(info.kind_of?(Hash) ? true : JSON.parse(info))
          end
        rescue JSON::ParserError
          false
        end
      end
    end
  end
end

