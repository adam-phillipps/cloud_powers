module Smash
  module CloudPowers
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

      # Search through a +Hash+ without knowing if the key is a +String+ or
      # +Symbol+.  A +String+ modification that _normalizes_ each value to compare
      # is used that is case insensitive.  It only leaves word characters, not
      # including underscore.  After the value is found, if it exists and can
      # be found, the +Hash+, minus that value, is returns in an +Array+ with
      # the element you were searching for
      #
      # Parameters
      # * key +String+|+Symbol+ - the key you are searching for
      # * hash +Hash+ - the +Hash+ to search through and return a modified copy
      #   from
      def find_and_remove(key, hash)
        candidate_keys = hash.select do |k,v|
          to_pascal(key).casecmp(to_pascal(k)) == 0
        end.keys

        interesting_value = hash.delete(candidate_keys.first)
        [interesting_value, hash]
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

      # Change valid JSON into a hash
      #
      # Parameter
      # * var +String+
      #
      # Returns
      # +Hash+ or +nil+ - +nil+ is returned if the JSON is invalid
      def from_json(var)
        begin
          JSON.parse(var)
        rescue JSON::ParserError, TypeError
          nil
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

      # Assure your arguments are a +Hash+
      #
      # Parameters
      # * start_point +Object+ - Best to start with a +Hash+, then a 2-D Array,
      #   then something +Enumerable+ that is at least Ordered
      #
      # Returns
      # +Hash+
      #
      # Notes
      # * If a +Hash+ is given, a copy is returned
      # * If an +Array+ is given,
      # * And if the +Array+ is a properly formatted, 2-D +Array+, <tt>to_h</tt>
      #   is called
      # * Else <tt>Hash[<default_key argument>, <the thing we're trying to turn into a hash>]</tt>
      def to_basic_hash(start_point, default_key: 'key')
        case start_point
        when Hash
          start_point
        when Enumerable
          two_dimensional_elements = start_point.select do |value|
            value.respond_to? :each
          end

          if two_dimensional_elements.count - start_point.count
            start_point.to_h
          else
            Hash[default_key, start_point]
          end
        else
          Hash[default_key, start_point]
        end
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
        return name if /\w+\.rb$/ =~ name
        "#{to_snake(name)}.rb"
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

      # Predicate method to check if a String is parsable, as JSON
      #
      # Parameters
      # * json +String+
      #
      # Returns
      # +Boolean+
      #
      # Notes
      # * See <tt>from_json</tt>
      def valid_json?(json)
        !!from_json(json)
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
