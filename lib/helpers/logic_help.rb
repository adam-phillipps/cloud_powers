module Smash
  module Helpers
    module LogicHelp
      # Sets an Array of instance variables, individually to a value that a
      # user given block returns.
      #
      # Parameters
      #
      # * keys +Array+
      # * * each object will be used as the name for the instance variable that
      #     your block returns
      # +block+ (optional)
      #   * this block is called for each object in the Array and is used as the value
      #   for the instance variable that is being named and created for each key
      # Returns Array
      #   * each object will either be the result of `#instance_variable_set(key, value)`
      #     or instance_variable_get(key)
      # Example
      #   keys = ['foo', 'bar', 'yo']
      #
      #   attr_map!(keys) { |key| sleep 1; "#{key}:#{Time.now.to_i}" }
      #   # => ['foo:1475434058', 'bar:1475434059', 'yo:1475434060']
      #
      #   puts @bar
      #   # => 'bar:1475434059'
      def attr_map!(keys)
        keys.map do |key|
          new_i_var = to_i_var(key)
          value = yield key if block_given?
          instance_variable_set(new_i_var, value) unless instance_variable_get(new_i_var)
        end
      end



      def available_resources(parent = Smash)
        parent.constants.select do |possible_resource|
          parent.const_get(possible_resource).is_a? Module
        end.compact.map do |v|

        end
      end



      # # This is a way to find out if you are trying to work with a resource
      # # available to CloudPowers
      # #
      # # Returns <Array>
      # # Use +.constants+ to find all the modules and classes available.
      # #
      # # Notes
      # # * TODO: make this smartly pick up all the objects, within reason and
      # #   considering need, that we have access to
      # def available_resources
      #   [:BrainFunc, :CloudPowers, :Helpers, :Job, :Task].concat(
      #     Smash.constants.map do |group_name|
      #       Smash.const_get(group_name).constants.select do |possible_resource|
      #         possible_resource.respond_to? :create
      #       end.collect.flatten
      #     end.flatten.uniq
      #   )
      # end






      # Does its best job at guessing where this method was called from, in terms
      # of where it is located on the file system.  It helps track down where a
      # project root is etc.
      #
      # Returns
      # +String+
      #
      # Notes
      # * Uses +$0+ to figure out what the current file is
      def called_from
        File.expand_path(File.dirname($0))
      end

      # Allows you to modify all first-level keys with a block that you pass.
      # If no block is passed, a copy is returned.
      #
      # Parameters
      # * params +Hash+|+Array+
      # * block (optional) - should modify the key and return that value so it can be used in the copy
      #
      # Returns
      # +Hash+|+Array+ - a copy of the given Array or Hash, with all Hash keys modified
      #
      # Example
      #   hash = { 'foo' => 'v1', 'bar' => { fleep: { 'florp' => 'yo' } } }
      #   modify_keys_with(hash) { |k| k.to_sym }
      #   # => { :foo => 'v1', :bar => { fleep: { 'florp' => 'yo' } } }
      #
      # Notes
      # * see +#deep_modify_keys_with()+ for handling nested keys
      # * case for different types taken from _MultiXML_ (multi_xml.rb)
      def modify_keys_with(params)
        params.inject({}) do |carry, (k, v)|
          carry.tap do |h|
            key = block_given? ? (yield k) : k
            h[key] = v
          end
        end
      end

      # Lets you retry a piece of logic with 1 second sleep in between attempts
      # until another bit of logic does what it's supposed to, kind of like
      # continuing to poll something and doing something when a package is ready
      # to be taken and processed.
      #
      # Parameters
      # * allowed_attempts +Number+|+Infinity(default)+ - The number of times
      #   the loop should be allowed to...well, loop, before a failed retry occurs.
      # * &test +Block+ - A predicate method or block of code that is callable
      #   is used to test if the block being retried is successful yet.
      # * []
      #
      # Example
      #   check_stuff = lambda { |params| return true }
      #   smart_retry(3, check_stuff(params)) { do_stuff_that_needs_to_be_checked }
      def smart_retry(test, allowed_attempts = Float::INFINITY)
        result = yield if block_given?
        tries = 1
        until test.call(result) || tries >= allowed_attempts
          result = yield if block_given?
          tries += 1
          sleep 1
        end
      end
    end
  end
end
