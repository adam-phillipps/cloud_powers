require 'json'
require 'cloud_powers/helpers'

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

      attr_accessor :package # The given data structure that is used to build @structure

      # Attempts to create a Context out of the argument(s) you've
      # passed.
      #
      # Parameters
      # * args +Hash+|+JSON+|+Array+|+Enumerable+
      # * * expample +Hash+:
      # * * * each key is a module or class that is in CloudPowers and each value
      #       is either an array of configurations information or a single configuration.
      #         { task: 'demo', queue: [:backlog, :sned], pipe: :status_stream }
      # * * expample Array
      # * * * each key is followed by 0..n valid configurations information
      #         [:task, 'demo', :queue, :backlog, :sned, :pipe, :status_stream]
      #
      # Returns
      # +Smash::Context+
      def initialize(args)
        unless valid_args?(args)
          raise ArgumentError.new 'Can be either a Hash, JSON, or an Enumerable ' +
            "arguments: #{args}"
        end
        @package = args
        @structure = decipher(args)
      end

      # Decipher figures out which translation method to use by making some simple type checks, etc.
      # and then routing the args to the correct method.
      #
      # Notes
      # * See +#translate_json()+
      # * See +#translate_list()+
      def decipher(args)
        case args
        when Hash
          args
        when String
          translate_json(args)
        when Enumerable
          translate_list(args)
        end
      end

      # Creates a flat Array of the 2-D Array that gets returned from `#simplify()`
      #
      # Returns +Array+
      #
      # Example
      #   example_context.structure
      #   # => { task: 'demo', queue: [:backlog, :sned], pipe: [:status_stream] }
      #   example.flatten
      #   # => [:task, 'demo', :queue, :backlog, :sned, :pipe, :status_stream]
      #
      # Notes
      # * See +#simplify()
      # * See +#Array::flatten()+
      def flatten
        simplify.flatten
      end

      # Create an array version of @sructure by calling `#to_a()` on it
      #
      # Returns
      # <tt>Array[Array..n]</tt>
      #
      # Example
      #   example_context.structure
      #   # => { task: 'demo', queue: [:backlog, :sned], pipe: [:status_stream] }
      #   example.simplify
      #   # => [:task, 'demo', :queue, [:backlog, :sned], :pipe, [:status_stream]]
      #
      # Notes
      # * This uses the different Constants, like Smash, Synapse and anything it can find
      #   to decide what should be used as a key and what its following values array should
      #   contain.  It basically says:
      #   1. if the nth item is a known key (from the above search), add it as an object in the Array.
      #   2. else, add it to the last sub-Array
      #   3. move to n+1 in the +structure Hash+
      # * TODO: Check if this has a limit to n-layers
      def simplify
        @structure.to_a
      end

      # A Hash that represents the resources and some configuration for them
      #
      # Returns +Hash+
      def structure
        modify_keys_with(@structure) { |key| key.to_sym }
      end

      # Valid scheme for @structure is assured by running the arguments through
      # the decipher method, which is how @structure is set in +#new(args)+
      def structure=(args)
        @structure = decipher(args)
      end

      # Parse the given JSON
      # Parameters
      # +JSON+
      # Returns
      # +Hash+
      def translate_json(json_string)
        begin
          JSON.parse(json_string)
        rescue JSON::ParserError
          raise ArgumentError "Incorrectly formatted JSON"
        end
      end

      # Re-layer this flattened Array or enumerable list so that it looks like the
      # Hash that it used to be before the Smash::Context#flatten() method was called
      #
      # Parameters
      # +Array+|+List+|+Enumerable+
      #
      # Example
      # * flat
      #
      #     [
      #       object_name_1, config_1a, config_2a, ...,
      #       object_2, config_1b, etc,
      #       ...
      #     ]
      #
      # * or grouped
      #
      #     [
      #       [object_name_1, config_1a, config_2a, ...],
      #       [object_2, config_1b, etc],
      #       ...
      #     ]
      #
      # * or structured
      #
      #     [
      #       [object_name_1, [config_1a, config_2a, ...]],
      #       [object_2, [config_1b, etc]],
      #       ...
      #     ]
      #
      # * returns
      #
      #     {
      #       object_1: [config_1a, config_2a, ...],
      #       object_2: [config_1b, ...],
      #       ...
      #     }
      # Returns
      # +Hash+
      #
      # Notes
      # If +#valid_package_hash?()+ is called on this Hash, it will return true
      def translate_list(list)
        list.first.kind_of?(Enumerable) ? translate_simplified(list) : translate_flattened(list)
      end

      # Translates an Array into a valid @structure Hash
      # Parameters arr <Array>
      # e.g.
      #   [:task, ['demo'], :queue, ['name1','name2',.,.,.,.,.], {other config hash},..., :pipe, ['name1']
      # Returns
      # +Hash+
      # Notes
      # * calling +#valid_hash_format?()+ on returned Hash will return true
      def translate_flattened(list)
        arr = list.to_a
        results = []
        # get the indexes of CloudPowers resources in arr
        key_locations = arr.each_with_index.collect do |key, i, _|
          i if available_resources.include?(to_pascal(key).to_sym)
        end.reject(&:nil?)
        key_locations << arr.size # add the last index into the ranges
        # use each pair as ranges to slice up the Array
        key_locations.each_cons(2) do |current_i, next_i|
          results << [arr[current_i], arr[(current_i+1)..(next_i-1)]]
        end

        translate_simplified(results)
      end

      # Translates a 2D Array into a valid @structure Hash
      # Parameters arr <Array>
      #   e.g.
      #   ```
      #     [
      #       [:task, 'demo'],
      #       [:queue, 'name1', {other config hash},...],
      #       [:pipe, 'name1']
      #       ...
      #     ]
      #   ```
      #   - Needs to be a 2D Array
      #   - First object of each inner-Array is the key
      #   - All following values in that inner Array are separate configuration
      #     information pieces that can be used in the `#create!()` method for that particular resource
      # Returns Hash
      #   well formatted for the @structure
      def translate_simplified(arr)
        arr.inject({}) do |hash, key_config_map|
          hash.tap do |h|
            key = key_config_map.shift
            h[key.to_sym] = *key_config_map.flatten
          end
        end
      end

      # Uses `#to_json()` on the @structure
      # Returns Hash
      def to_json
        structure.to_json
      end

      # The Context class can be initialized in any of the formats that a Context
      # class _should_ exist in.  It can be a vanilla version, where the @structure
      # is a Hash, structured correctly or it can be serialized into JSON or it can
      # be an Array
      # Parameters args String
      # Returns Boolean
      def valid_args?(args)
        case args
        when Hash
          valid_hash_format?(args)
        when String
          valid_json_format?(args)
        when Enumerable
          valid_array_format?(args)
        else
          false
        end
      end

      # Makes sure that the list is enumerable and that at least the first term
      # is a resource name from Smash::CloudPowers.  All other objects can
      # potentially be configurations.
      # Parameters list <Array|Enumerable>
      # Returns Boolean
      def valid_array_format?(list)
        use = list.first.kind_of?(Enumerable) ? list.first.first : list.first
        ((list.kind_of? Enumerable) && (available_resources.include?(to_pascal(use).to_sym)))
      end

      # Makes sure that each key is the name of something CloudPowers can interact with
      # Parameters hash <Hash>
      # Returns Boolean
      def valid_hash_format?(hash)
        keys_arr = hash.keys.map { |key| to_pascal(key).to_sym }
        (keys_arr - available_resources).empty?
      end

      # Parses the json_string which yields a Hash or an exception.  From there,
      # use the #valid_hash_format?() method
      def valid_json_format?(json_string)
        begin
          valid_hash_format?(JSON.parse(json_string))
        rescue JSON::ParserError
          false
        end
      end
    end
  end
end
