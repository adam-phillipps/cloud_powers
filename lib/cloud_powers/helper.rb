require 'logger'
require 'pathname'
require 'syslog/logger'
require_relative 'smash_error'
require_relative 'auth'
require 'byebug'

module Smash
  module CloudPowers
    module Helper
      include Smash::CloudPowers::Auth

      def attr_map!(keys)
        keys.map do |attr|
          key = to_i_var(attr)
          value = yield key if block_given?
          instance_variable_set(key, value)
        end
      end

      def env(key)
        ENV[to_snake(key).upcase]
      end

      def create_logger
        logger = Logger.new(STDOUT)
        logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        logger
      end

      def errors
        # TODO: needs work
        $errors ||= SmashError.instance
      end

      def format_error_message(error)
        begin
          [error.message, error.backtrace.join("\n")].join("\n")
        rescue Exception => e
          # if the formatting won't work, return the original exception
          error
        end
      end

      # Gets the path from the environment and sets @log_file using the path
      # @returns @log_file path <String>
      def log_file
        @log_file ||= env('LOG_FILE')
      end

      # @returns: An instance of Logger, cached as @logger
      def logger
        @logger ||= create_logger
      end

      # Lets you retry a piece of logic with 1 second sleep in between attempts
      # until another bit of logic does what it's supposed to, kind of like
      # continuing to poll something and doing something when a package is ready
      # to be taken and processed.
      # @params:
      #   * [allowed_attempts] or Infinity(default) <Number>: The number of times
      #       the loop should be allowed to...well, loop, before a failed retry occurs.
      #   * &test <Block>: A predicate method or block of code that is callable
      #       is used to test if the block being retried is successful yet.
      #   * []
      # Sample usage:
      # check_stuff = lambda { |params| return true }
      # smart_retry(3, check_stuff(params)) { do_stuff_that_needs_to_be_checked }
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
      # @params:
      #   * [file] <String>: name of a file
      # @returns:
      #   * path[/file] <String>
      #   * If a `file` is given, it will have a '.rb' file extension
      #   * If no `file` is given, it will return the `#task_require_path`
      def task_path(file = '')
        return task_require_path if file.empty?
        Pathname(__FILE__).parent.dirname + 'tasks' + to_ruby_file_name(file)
      end

      # Gives the path from the project root to lib/tasks[/file]
      # @params:
      #   * [file] <String>: name of a file
      # @returns:
      #   * path[/file] <String>
      #   * Neither path nor file will have a file extension
      def task_require_path(file_name = '')
        file = File.basename(file_name, File.extname(file_name))
        Pathname(__FILE__).parent.dirname + 'tasks' + file
      end

      def to_camel(var)
        var = var.to_s unless var.kind_of? String
        step_one = to_snake(var)
        step_two = to_pascal(step_one)
        step_two[0, 1].downcase + step_two[1..-1]
      end

      def to_i_var(var)
        "@#{to_snake(var)}"
      end

      def to_pascal(var)
        var = var.to_s unless var.kind_of? String
        var.gsub(/^(.{1})|\W.{1}|\_.{1}/) { |s| s.gsub(/[^a-z0-9]+/i, '').capitalize }
      end

      def to_ruby_file_name(name)
        name[/\.rb$/].nil? ? "#{to_snake(name)}.rb" : "#{to_snake(name)}"
      end

      def to_snake(var)
        var = var.to_s unless var.kind_of? String

        # var.gsub(/\W/, '_').downcase
        var.gsub(/:{2}|\//, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          gsub(/\s+/, '_').
          tr("-", "_").
          downcase
      end

      def update_message_body(opts = {})
        # TODO: find better implementation of merging nested hashes
        # this should be fixed with Job #sitrep_message
        # TODO: find a way to trim this method down and get rid
        # of a lof of the repitition with these messages
        # IDEA: throw events and have a separate thread listening. the separate
        # thread could be a communication or status update thread
        unless opts.kind_of? Hash
          update = opts.to_s
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
