require 'spec_helper'
require 'dotenv'

describe 'Synapse::WebSocServer' do
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
  end
end
