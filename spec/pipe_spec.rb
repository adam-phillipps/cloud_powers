require 'spec_helper'
require 'dotenv'

describe 'Synapse::Pipe' do
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
  end
end
