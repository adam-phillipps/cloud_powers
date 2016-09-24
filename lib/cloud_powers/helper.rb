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

      def log_file
        @log_file ||= env('LOG_FILE')
      end

      def logger
        @logger ||= create_logger
      end

      # Sample usage:
      # check_stuff = lambda { |params| return true }
      # retry(3, check_stuff(params)) { do_stuff_that_needs_to_be_checked }
      def retry(allowed_attempts = Float::Infinity, &test)
        result = yield if block_given?
        tries = 1
        until test.call(result) || tries >= allowed_attempts
          result = yield if block_given?
          sleep 1
        end
      end

      def task_path(file = '')
        # t_p = Pathname(__FILE__).parent.dirname + 'tasks'
        if file.empty?
          Pathname(__FILE__).parent.dirname + 'tasks'
        else
          Pathname(__FILE__).parent.dirname + "tasks/#{to_snake(file)}"
        end
      end

      def task_require_path(file_name)
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
        "#{to_snake(name)}.rb"
      end

      def to_snake(var)
        file_ext = var.to_s[/\.{1}[a-z]+$/] || ''
        var.to_s.gsub(/\.\w+$/, '').gsub(/\W/, '_').downcase + file_ext
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
