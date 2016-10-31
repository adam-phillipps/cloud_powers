require 'helpers/lang_help'
require 'helpers/path_help'
require 'helpers/logic_help'

module Smash
  module Helpers
    include Smash::Helpers::LangHelp
    include Smash::Helpers::LogicHelp
    include Smash::Helpers::PathHelp
  end
end
