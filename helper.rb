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
          key = rubyize(attr)
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
        {
          instanceId:       opts[:instanceId] || @instance_id,
          type:             opts[:type] || 'status_update',
          content:          opts[:content] || 'running',
          extraInfo:        opts[:extraInfo] || {}
        }.merge(opts).to_json
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
