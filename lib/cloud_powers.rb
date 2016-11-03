require 'cloud_powers/auth'
require 'cloud_powers/aws_resources'
require 'cloud_powers/node'
require 'cloud_powers/storage'
require 'cloud_powers/version'
require 'brain_func/cerebrum_functions'
require 'brain_func/context'
require 'brain_func/delegator'
require 'brain_func/neuron_functions'
require 'brain_func/self_awareness'
require 'brain_func/workflow_factory'
require 'helpers/lang_help'
require 'helpers/path_help'
require 'helpers/logic_help'
require 'logger'

# The Smash module allows us to use CloudPowers under a shared name space with
# other projects.
module Smash
  # Helpers provide you with a few types of assistance.  You can get help with
  # translating variables, understanding what resources a given project has and
  # where to store everything for a dynamically changing project.
  module Helpers
    # various common methods to alter or translate messages, var names etc
    include Smash::Helpers::LangHelp
    # various common methods to help aid a larger problem.  You can gather available
    # resources in a namespace, find out where a method was called from and other
    # useful introspection assists
    include Smash::Helpers::LogicHelp
    # various methods to help tie projects together.  If you want to know how
    # your path is being referenced or you need a nice place to keep things in
    # order, use the path helpers.
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
  # You can build custom workflows and attach them to jobs, decide on a class
  # dynamically and run a job, from start to finish, inside a serialized context,
  # automatically and it can all be done in a few lines of code.
  module BrainFunc
    # Methods to help tie a few jobs together
    include Smash::BrainFunc::CerebrumFunctions
    # Problem context awareness, building assist and serialization
    # <tt>Context</tt> +Class+
    # Dynamic Class use
    include Smash::BrainFunc::Delegator
    # Methods to help you brutalize a hard job
    include Smash::BrainFunc::NeuronFunctions
    # Gathers data about an instance, itself
    include Smash::BrainFunc::SelfAwareness
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
    # Store files
    include Smash::CloudPowers::Storage
    # Communication modules
    include Smash::CloudPowers::Synapse
    # CRUD on Nodes, which are individual instances
    include Smash::CloudPowers::Node
  end
end
