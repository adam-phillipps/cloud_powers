require 'json'
require 'cloud_powers/helpers'
# ~55 lines of code
module Smash
  module BrainFunc
    # The Context class is the class that handles serializing the Context so that it
    # can be passed from node to node and rebuilt.  This provides a way for nodes in
    # the same Brain to have an awareness of required communication modes, for example.
    # Because resources generally require some sort of information to connect with
    # or create and a Brain operates in the same Context, it can use the Context to
    # decouple the creation and usage from the coordination.
    class Context
      include Smash::CloudPowers::Helpers
      include Smash::CloudPowers::Zenv

      # The "deciphered" description that was received to build this +Context+
      #
      # Example
      #     {
      #       job:    ['demo'],
      #       queue:  [{ name: :backlog }, { name: :sned }],
      #       pipe:   [{ name: :status }]
      #     }
      attr_reader :description
      # The main-highest-parent Job that started this whole mess
      attr_reader :job
      # The given name of this context
      attr_reader :name
      # The name used to find this resource, in the form of <tt>@name_context</tt>
      attr_reader :call_name

      # Attempts to create a Context out of the argument(s) you've passed.
      #
      # Parameters
      # * args +Hash+|+JSON+
      #
      # Returns
      # <tt>Smash::Context</tt>
      #
      # Expample
      # * +Hash+ - each key is a module or class that is in CloudPowers and each
      #   value is an array of configurations information.
      #       { job: ['demo'], queue: [{name: :backlog}, {name: :sned}], pipe: [{name: :status}] }
      def initialize(*args)
        argument_hash = to_basic_hash(*args, default_key: 'job')
        @job, @description = separate_args(argument_hash)

        if @job.nil?
          raise ArgumentError.new('invalid args: ' + args.join("\n"))
        end

        @name = to_snake(@job)
        @call_name = "#{@name}_context"
        @description ||= default_description
      end

      # Add a resource description to this Context
      #
      # Parameters
      # * type +KeywordArgument+ - the type of resource to be added
      # * config +KeywordArgument+(s) (optional) - the configuration for the new
      #   resource
      #
      # Returns
      # +Array+ - all resource descriptions for this type
      def add_to(type:, **config)
        @description[type] += [config]
      end

      # Remove a resource description from this Context
      #
      # Parameters
      # * type +KeywordArgument+ - the type of resource to be added
      # * config +KeywordArgument+(s) (optional) - the configuration for the new
      #   resource
      #
      # Returns
      # +Hash+ - deleted resource config
      def remove_from(name:, type:)
        @description[type].delete_if { |config| config[:name] == name }
      end

      # Separate the Job argument from everything else and return the two
      # as separate values
      #
      # Parameters
      # +Hash+|+JSON+ (JSON must be a valid representation of a valid +Hash+)
      #
      # Returns
      # +Array+
      # * if only a Job is given
      #       separate_args(job: 'test')
      #       => ['test', {}]
      # # if +Job+ and +Hash+ are given
      #       separate_args(job: 'test', board: [{name: updates}])
      #       => ['test', {board: [{name: 'updates'}]}]
      def separate_args(args)
        case args
        when self.class
          byebug
          [args.job, args.description]
        when Enumerable
          find_and_remove('job', to_basic_hash(args))
        when String
          separate_args(from_json(args)) || [to_pascal(args), {}]
        else
          Array.new(2)
        end
      end

      # Serialize this +Context+
      #
      # Returns
      # +JSON+ - JSON representation of the <tt>@description</tt>
      def to_json
        @description.to_json
      end

      private
      def default_description
        { board: [{ name: 'waiting' }, { name: 'in progress' }] }
      end
    end
  end
end
