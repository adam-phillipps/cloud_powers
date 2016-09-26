require 'dotenv'
require_relative 'helper'
module Smash
  module CloudPowers
    # This module provides some environment variable management and functionality
    # System ENV, dotenv ENV and instance variables are considered for now but this
    # will also use elasticache/redis...some other stuff too, in the coming weeks
    module Zenv
      include Smash::CloudPowers::Helper

      # Attempts to find a file by searching the current directory for the file
      # then walking up the file tree and searching at each stop
      # @param: name <String>: name of the file or directory to find
      # @return: Pathname: path to the file or directory given as the `name` param
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

      # Search through the .env variables for a key or if no key is given,
      # return all the .env-vars and their values
      def env_vars(key = '')
        return ENV if key.empty?
        ENV[to_snake(key).upcase]
      end

      # Search through the instance variables for a key or if no key is given,
      # return all the i-vars and their values
      # @params: [key <String]:  The key to search for
      # @return:
      def i_vars(key = '')
        if key.empty?
          return self.instance_variables.inject({}) do |r,v|
            r.tap { |h| h[to_snake(v)] = self.instance_variable_get(to_i_var(v)) }
          end
        end
        self.instance_variable_get(to_i_var(key))
      end

      # PROJECT_ROOT should be set as early as possible in this Node's initilize
      # method.  This method tries to search for it, using #zfind() and if a `nil`
      # result is returned from that search, `pwd` is used as the PROJECT_ROOT.
      # @return: Path to the project root or where ever `pwd` resolves to <Pathname>
      # TODO: improve this...it needs to find the gem's method's caller's project
      # root or at least the gem's method's caller's file's location.
      def project_root
        byebug
        if @project_root.nil?
          file_home = Pathname.new(
            caller_locations.first.path.strip.split(/\//).first).realdirpath.parent
          path = (zfind('PROJECT_ROOT') or file_home)
          @project_root = Pathname.new(file_home)
        end
        @project_root
      end

      # Manually set the `@project_root` i-var as a `Pathname` object.
      # @param: New path to the project root <String|Pathname>
      # @return: @project_root <Pathname>
      def project_root=(var)
        @project_root = Pathname.new(var)
      end

      # Search through the system environment variables for a key or if no key
      # is given, return all the system-env-vars and their values
      # @params: [key <String>]:  The key to search for
      # @return: Value <String> for the given key or if no key was given, a
      # Hash with { key => value, ... } is returned for all keys with a value.
      # Keys with no value are ommitted from the result.
      def system_vars(key = '')
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
          res = `printf "#{to_snake(key).upcase}"`
          return res.empty? ? nil : res
        end
      end

      # ZFind looks for the key in a preditermined order of importance:
      #   * i-vars are considered first becuase they might be tracking different
      #     locations for multiple tasks or something like that.
      #   * dotenv files are second because they were manually set, so for sure
      #     it's important
      #   * System Env[@] variables are up next.  Hopefully by this time we've found
      #     our information but if not, it should "search" through the system env too.
      # @params: key <String>: The key to search for
      # @return: <String>
      #   TODO: implement a search for all 3 that can find close matches
      def zfind(key)
        res = (i_vars[to_snake(key).upcase] or
          env_vars[to_snake(key).upcase] unless @project_root.nil?) or
          system_vars[to_snake(key).upcase]
        (res.nil? or res.empty?) ? nil : res
      end
    end
  end
end
