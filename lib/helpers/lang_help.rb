module Smash
  module Helpers
    # The LangHelp module provides common methods to help manage small differences
    # between many system's messages, e.g. the <tt>to_camel()</tt> method, for
    # changing a variable name into something Java or Java Script might like better.
    module LangHelp
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
        rescue Exception
          # if the formatting won't work, return the original exception
          error
        end
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

      # Change strings into camelCase
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      def to_camel(var)
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
        var.to_s.gsub(/:{2}|\//, '-').
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
        /^\W*@\w+/ =~ var.to_s ? to_snake(var) : "@#{to_snake(var)}"
      end

      # Change strings into PascalCase
      #
      # Parameters
      # * var +String+
      #
      # Returns
      # +String+
      def to_pascal(var)
        var.to_s.gsub(/^(.{1})|\W.{1}|\_.{1}/) { |s| s.gsub(/[^a-z0-9]+/i, '').capitalize }
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
        var.to_s.gsub(/:{2}|\//, '_').
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
        rescue Exception
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
