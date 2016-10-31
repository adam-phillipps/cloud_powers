require 'cloud_powers/auth'
require 'cloud_powers/aws_resources'
require 'cloud_powers/node'
require 'cloud_powers/self_awareness'
require 'cloud_powers/storage'
require 'cloud_powers/version'
require 'brain_func/cerebrum_functions'
require 'brain_func/context'
require 'brain_func/delegator'
require 'brain_func/neuron_functions'
require 'brain_func/workflow_factory'
require 'helpers/lang_help'
require 'helpers/path_help'
require 'helpers/logic_help'
require 'logger'

# The Smash module allows us to use CloudPowers under a shared name space with
# other projects.
module Smash
  module Helpers
    include Smash::Helpers::LangHelp
    include Smash::Helpers::LogicHelp
    include Smash::Helpers::PathHelp

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
      logger = ::Logger.new(log_to)
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
  # BrainFunc is the power in CloudPowers.
  # You can build custom workflows and attach them to tasks, decide on a class
  # dynamically and run a job, from start to finish, inside a serialized context,
  # automatically and it can all be done in a few lines of code.
  module BrainFunc
    # Methods to help tie a few tasks together
    include Smash::BrainFunc::CerebrumFunctions
    # Problem context awareness, building assist and serialization
    # <tt>Context</tt> +Class+
    # Dynamic Class use
    include Smash::BrainFunc::Delegator
    # Methods to help you brutalize a hard task
    include Smash::BrainFunc::NeuronFunctions
    # Dynamic, responsive workflows
    include Smash::BrainFunc::WorkflowFactory
  end

  # The CloudPowers module contains all the other modules and classes that
  # give you access to cloud resources.  At the moment, AWS is all that exists
  # but a port or addition of Azure is comming soon...
  module CloudPowers
    # Authentication mixin
    extend Smash::CloudPowers::Auth
    # Aws clients, like EC2 and S3
    include Smash::CloudPowers::AwsResources
    # Various helper methods
    include Smash::Helpers
    # Gathers data about an instance, itself
    include Smash::CloudPowers::SelfAwareness
    # Store files
    include Smash::CloudPowers::Storage
    # Communication modules
    include Smash::CloudPowers::Synapse
    # CRUD on Nodes, which are individual instances
    include Smash::CloudPowers::Node
  end
end
