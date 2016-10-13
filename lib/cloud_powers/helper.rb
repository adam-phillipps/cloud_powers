require 'logger'
require 'pathname'
require 'uri'
require 'syslog/logger'
require_relative 'smash_error'

module Smash
  module CloudPowers
    module Helper

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

      # This is a way to find out if you are trying to work with a resource
      # available to CloudPowers
      #
      # Returns <Array>
      # Use +.constants+ to find all the modules and classes available.
      #
      # Notes
      # * TODO: make this smartly pick up all the objects, within reason and
      #   considering need, that we have access to
      def available_resources
        [:Task].concat(Smash::CloudPowers.constants)
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

      # creates a default logger
      #
      # Parameters
      # * log_to +String+ (optional) - location to send logging information to; default is STDOUT
      #
      # Returns
      # +Logger+
      #
      # Notes
      # * TODO: at least make this have overridable defaults
      def create_logger(log_to = STDOUT)
        logger = Logger.new(log_to)
        logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        logger
      end

      # Allows you to modify all keys, including nested, with a block that you pass.
      # If no block is passed, a copy is returned.
      #
      # Parameters
      # * params +Hash+|+Array+ - hash to be modified
      # * +block+ (optional) - a block to be used to modify each key should
      #   modify the key and return that value so it can be used in the copy
      #
      # Returns
      # +Hash+|+Array+ - a copy of the given Array or Hash, with all Hash keys modified
      #
      # Example
      #   hash = { 'foo' => 'v1', 'bar' => { fleep: { 'florp' => 'yo' } } }
      #   modify_keys_with(hash) { |key| key.to_sym }
      #   # => { foo: 'v1', bar: { fleep: { florp: 'yo' } } }
      #
      # Notes
      #   * see `#modify_keys_with()` for handling first-level keys
      #   * see `#pass_the_buck()` for the way nested structures are handled
      #   * case for different types taken from _MultiXML_ (multi_xml.rb)
      #   * TODO: look at optimization
      def deep_modify_keys_with(params)
        case params
        when Hash
          params.inject({}) do |carry, (k, v)|
            carry.tap do |h|
              if block_given?
                key = yield k

                value = if v.kind_of?(Hash)
                    deep_modify_keys_with(v) { |new_key| Proc.new.call(new_key) }
                  else
                    v
                  end

                h[key] = value
              else
                h[k] = v
              end
            end
          end
        when Array
          params.map{ |value| symbolize_keys(value) }
        else
          params
        end
      end

      # Join the message and backtrace into a String with line breaks
      #
      # Parameters
      # * error +Exception+
      #
      # Returns
      # +String+
      def format_error_message(error)
        begin
          [error.message, error.backtrace.join("\n")].join("\n")
        rescue Exception => e
          # if the formatting won't work, return the original exception
          error
        end
      end

      # Gets the path from the environment and sets @log_file using the path
      #
      # Returns
      # @log_file +String+
      #
      # Notes
      # * See +#zfind()+
      def log_file
        @log_file ||= zfind('LOG_FILE')
      end

      # Returns An instance of Logger, cached as @logger@log_file path <String>
      #
      # Returns
      # +Logger+
      #
      # Notes
      # * See +#create_logger+
      def logger
        @logger ||= create_logger
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

      # Gives the path from the project root to lib/tasks[/#{file}.rb]
      #
      # Parameters
      # * file +String+ (optional) (default is '') - name of a file
      #
      # Returns
      # * path/file +String+ if +file+ parameter is given.  return has
      #   '.rb' extension included
      # * file +String+ if +file+ parameter is not given it will return the <tt>#task_require_path()</tt>
      #
      # Notes
      # * See <tt>#task_require_path()</tt>
      def task_path(file = '')
        return task_require_path if file.empty?
        Pathname(__FILE__).parent.dirname + 'tasks' + to_ruby_file_name(file)
      end

      # Gives the path from the project root to lib/tasks[/file]
      #
      # Parameters String (optional)
      # * file_name name of a file
      #
      # Returns
      # * path/file +String+ if +file_name+ was given
      # * path to task_directory if +file_name+ was <i>not</i> given
      #
      # Notes
      # * Neither path nor file will have a file extension
      def task_require_path(file_name = '')
        file = File.basename(file_name, File.extname(file_name))
        Pathname(__FILE__).parent.dirname + 'tasks' + file
      end

      # Change strings into camelCase
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      def to_camel(var)
        var = var.to_s unless var.kind_of? String
        step_one = to_snake(var)
        step_two = to_pascal(step_one)
        step_two[0, 1].downcase + step_two[1..-1]
      end

      # Change strings into a hyphen delimited phrase
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      def to_hyph(var)
        var = var.to_s unless var.kind_of? String

        var.gsub(/:{2}|\//, '-').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          gsub(/\s+/, '-').
          tr("_", "-").
          gsub(/^\W/, '').
          downcase
      end

      # Change strings into an i-var format
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      def to_i_var(var)
        var = var.to_s unless var.kind_of? String
        /^\W*@\w+/ =~ var ? to_snake(var) : "@#{to_snake(var)}"
      end

      # Change strings into PascalCase
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      def to_pascal(var)
        var = var.to_s unless var.kind_of? String
        var.gsub(/^(.{1})|\W.{1}|\_.{1}/) { |s| s.gsub(/[^a-z0-9]+/i, '').capitalize }
      end

      # Change strings into a ruby_file_name with extension
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      #
      # Notes
      # * given_string.rb
      # * includes ruby file extension
      # * see #to_snake()
      def to_ruby_file_name(name)
        name[/\.rb$/].nil? ? "#{to_snake(name)}.rb" : "#{to_snake(name)}"
      end

      # Change strings into PascalCase
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      #
      # Notes
      # * given_string
      # * will not have file extensions
      # * see #to_ruby_file_name()
      def to_snake(var)
        var = var.to_s unless var.kind_of? String

        var.gsub(/:{2}|\//, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          gsub(/\s+/, '_').
          tr("-", "_").
          downcase
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

      # Predicate method to check if a String is parsable, as JSON
      #
      # Parameters
      # * json +String+
      #
      # Returns
      # +Boolean+
      def valid_json?(json)
        begin
          JSON.parse(json)
          true
        rescue Exception => e
          false
        end
      end

      # Predicate method to check if a String is a valid URL
      #
      # Parameters
      # * url +String+
      #
      # Returns
      # +Boolean+
      def valid_url?(url)
        url =~ /\A#{URI::regexp}\z/
      end
    end
  end
end
