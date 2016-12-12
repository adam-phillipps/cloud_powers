module Smash
  module CloudPowers
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
      # Returns +Array+ - each object will either be the result of
      # <tt>#instance_variable_set(key, value)</tt> => +value+
      #     or instance_variable_get(key)
      # Example
      #   keys = ['foo', 'bar', 'yo']
      #
      #   attr_map!(keys) { |key| sleep 1; "#{key}:#{Time.now.to_i}" }
      #   # => ['foo:1475434058', 'bar:1475434059', 'yo:1475434060']
      #
      #   puts @bar
      #   # => 'bar:1475434059'
      def attr_map(attributes)
        attributes = [attributes, nil] unless attributes.respond_to? :map

        attributes.inject(self) do |this, (attribute, before_value)|
          first_place, second_place = yield attribute, before_value if block_given?

          results = if second_place.nil?
            [attribute, first_place]
          else
            [first_place, second_place]
          end

          this.instance_variable_set(to_i_var(results.first), results.last)
          this
        end
      end

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

      # Create an <tt>attr_accessor</tt> feeling getter and setter for an instance
      # variable.  The method doesn't create a getter or setter if it is already
      # defined.
      #
      # Parameters
      # * base_name +String+ - the name, without the '@' symbol
      #     # ok
      #     add_instance_attr_accessor('my_variable_name', my_value)
      #     => <your_instance @my_variable_name=my_value, ...>
      #     # not ok
      #     add_instance_attr_accessor('@#!!)', my_value)
      #     => <your_instance> <i>no new instance variable found</i>
      # * value +Object+ - the actual instance variable that matches the +base_name+
      #
      # Returns
      # * the value of the instance variable that matches the +base_name+ (first) argument
      #
      # Notes
      # * if a matching getter or setter method can be found, this method won't
      #   stomp on it.  nothing happens, in that case
      # * if an appropriately named instance variable can't be found, the getter
      #   method will return nil until you set it again.
      # * <b>it is the responsibility of you and me to make sure our variable names
      #   are valid, i.e. proper Ruby instance variable names
      def instance_attr_accessor(base_name)
        i_var_name = to_i_var(base_name)
        getter_signature = to_snake(base_name)
        setter_signature = "#{getter_signature}="

        unless respond_to? getter_signature
          define_singleton_method(getter_signature) do
            instance_variable_get(i_var_name)
          end
        end

        unless respond_to? setter_signature
          define_singleton_method(setter_signature) do |argument|
            instance_variable_set(i_var_name, argument)
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

      # This method provides a default overrideable message body for things like
      # basic status updates.
      #
      # Parameters
      # * instanceId +Hash+
      #
      # Notes
      # * camel casing is used on the keys because most other languages prefer
      #   that and it's not a huge problem in ruby.  Besides, there's some other
      #   handy methods in this module to get you through those issues, like
      #   +#to_snake()+ and or +#modify_keys_with()+
      def update_message_body(opts = {})
        # TODO: Better implementation of merging message bodies and config needed
        unless opts.kind_of? Hash
          update = opts.to_s
          opts = {}
          opts[:extraInfo] = { message: update }
        end
        updated_extra_info = opts.delete(:extraInfo) || {}

        {
          instanceId:       @instance_id || 'none-aquired',
          type:             'status-update',
          content:          'running',
          extraInfo:        updated_extra_info
        }.merge(opts)
      end
    end
  end
end
