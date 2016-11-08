require 'logger'
require 'syslog/logger'
require 'cloud_powers/helpers/lang_help'
require 'cloud_powers/helpers/logic_help'
require 'cloud_powers/helpers/path_help'

module Smash
  module CloudPowers
    module Helpers
      include Smash::CloudPowers::LangHelp
      include Smash::CloudPowers::LogicHelp
      include Smash::CloudPowers::PathHelp

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
    end
  end
end
