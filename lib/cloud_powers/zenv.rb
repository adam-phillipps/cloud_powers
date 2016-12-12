require 'dotenv'
require 'cloud_powers/helpers'

module Smash
  module CloudPowers
    # This module provides some environment variable management and functionality
    # Hopefully it should provide us with some "Zen", when dealing with normally
    # annoying env issues.  Meh, it probably won't but I like the name, so it stays :}
    # System ENV, dotenv ENV and instance variables are considered for now but this
    # will also use elasticache/redis...some other stuff too, in the coming versions
    module Zenv
      include Smash::CloudPowers::Helpers

      # Attempts to find a file by searching the current directory for the file
      # then walking up the file tree and searching at each stop all the way up
      # to the root directory
      #
      # Parameters
      # * name +String+ - name of the file or directory to find
      #
      # Returns
      # +Pathname+ - path to the file or directory given as the +name+ parameter
      def file_tree_search(name)
        next_dir = Pathname.new(`pwd`.strip).parent
        current_dir = Pathname.new(`pwd`.strip)
        until(next_dir == current_dir) do
          path = Dir.glob("#{current_dir}/#{name}").first
          return current_dir unless path.nil?
          current_dir = next_dir
          next_dir = next_dir.parent
        end
        return nil
      end

      # Search through the {Dotenv}[https://github.com/bkeepers/dotenv]
      # variables for a key or if no key is given, return all the .env-vars
      # and their values
      #
      # Parameters
      # * key +String+ -
      def env_vars(key = '')
        return ENV if key.empty?
        ENV[to_snake(key).upcase]
      end

      # Search through the instance variables for a key or if no key is given,
      # return all the i-vars and their values
      #
      # Parameters [key <String]:  The key to search for
      #
      # Returns
      # the value of the +key+ searched for
      def i_vars(key = '')
        name = to_i_var(key)

        # if no key is given, return a +Hash+ of all i-var/value pairs
        if key.empty?
          return self.instance_variables.inject({}) do |r, v|
            r.tap { |h| h[name] = self.instance_variable_get(name) }
          end
        end

        self.instance_variable_get(name)
      end

      # PROJECT_ROOT should be set as early as possible in this Node's initilize
      # method.  This method tries to search for it, using #zfind() and if a `nil`
      # result is returned from that search, `pwd` is used as the PROJECT_ROOT.
      #
      # Returns
      # +Pathname+ - path to the project root or where ever <tt>`pwd`</tt> resolves
      # to for the caller
      #
      # Notes
      # * TODO: improve this...it needs to find the gem's method's caller's project
      # root or at least the gem's method's caller's file's location.
      #
      # Example
      #   # called from cerebrum/cerebrum.rb in /home/ubuntu
      #   project_root
      #   # => '/home/ubuntu/cerebrum/'
      #   # or
      #   # called from go_nuts.rb#begin_going_crazy():(line -999999999.9) in /Users/crazyman/.ssh/why/all/the/madness/
      #   project_root
      #   # => '/Users/crazyman/.ssh/why/all/the/madness/'
      def project_root
        if @project_root.nil?
          file_home = Pathname.new(
            caller_locations.first.path.strip.split(/\//).last).realdirpath.parent
          # path = (zfind('PROJECT_ROOT') or file_home)
          @project_root = Pathname.new(file_home)
        end
        @project_root
      end

      # Manually set the +@project_root+ i-var as a +Pathname+ object.
      #
      # Parameters
      # * +String+|+Pathname+ - new path to the project root
      #
      # Returns
      # +Pathname+ - +@project_root+
      #
      # Example
      #   project_root
      #   # => '/home/ubuntu/cerebrum/'
      #   project_root = Pathname.new(`pwd`)
      #   project_root == `pwd`
      #   # => true
      def project_root=(var)
        @project_root = Pathname.new(var)
      end

      # Search through the system environment variables for a key or if no key
      # is given, return all the system-env-vars and their values
      #
      # Parameters
      # * key +String+ - the key to search for
      #
      # Returns
      # * if a +key+ is given as a parameter, +String+
      # * if no +key+ is given as a parameter, +Hash+
      # with this structure +{ key => value, ... }+ is returned for all keys with a value.
      # Keys with no value are ommitted from the result.
      def system_vars(key = '')
        name = to_snake(key).upcase
        if key.empty?
          # Separate key-value pairs from the large string received by `ENV`
          separate_pairs = `ENV`.split(/\n/).map do |string_pair|
            string_pair.split('=')
          end
          # Separate key-value pairs from each other into a hash of
          # { key => value, other_key => other_value }
          #   * keys with no value are removed
          separate_pairs.inject({}) do |res, pair|
            res.tap { |h_res| h_res[pair.first] = pair.last unless (pair.first == pair.last) }
          end
        else
          Object::ENV.has_key?(name) ? Object::ENV.fetch(name) : nil
        end
      end

      # ZFind looks for the key in a preditermined order of importance:
      # * i-vars are considered first becuase they might be tracking different
      #   locations for multiple jobs or something like that.
      # * dotenv files are second because they were manually set, so for sure
      #   it's important
      # * System Env[@] variables are up next.  Hopefully by this time we've found
      #   our information but if not, it should "search" through the system env too.
      #
      # Parameters
      # * key +String+|+Symbol+ - the key to search for
      #
      # Returns
      # * +String+
      #
      # Notes
      # * TODO: implement a search for all 3 that can find close matches
      def zfind(key)
        project_root if @project_root.nil?
        i_vars(key) || env_vars(key) || system_vars(key)
      end
    end
  end
end
