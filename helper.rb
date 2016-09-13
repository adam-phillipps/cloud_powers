require 'syslog/logger'
require 'logger'
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
        ENV[key.to_s.upcase] if ENV.keys.include?(key.to_s.upcase)
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

      def to_i_var(var)
        "@#{to_snake(var)}"
      end

      def to_snake(var)
        var.gsub(/\W/, '_').downcase
      end

      def to_camal(var)
        var.gsub(/^(.{1})|\_.{1}/) { |s| s.gsub(/[^a-z0-9]+/i, '').capitalize }
      end

      def to_pascal(var)
        step_one = to_snake(var)
        step_two = to_camal(step_one)
        step_two[0, 1].downcase + step_two[1..-1]
      end

      # Sample usage:
      # check_stuff = lambda { |params| return true }
      # retry(3, check_stuff(params)) { do_stuff_that_needs_to_be_checked }
      def retry(allowed_attempts = Float::Infinity, &block)
        result = yield if block_given?
        tries = 1
        until block.call(result) || tries >= allowed_attempts
          result = yield if block_given?
          sleep 1
        end
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
        udpated_extra_info = opts.delete(:extraInfo) || {}

        {
          instanceId:       @instance_id || 'none-aquired',
          type:             'status-update',
          content:          'running',
          extraInfo:        udpated_extra_info
        }.merge(opts)
      end

      def log_file
        @log_file ||= env('LOG_FILE')
      end

      def logger
        @logger ||= create_logger
      end

      def create_logger
        logger = Logger.new(STDOUT)
        logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        logger
      end
    end
  end
end
