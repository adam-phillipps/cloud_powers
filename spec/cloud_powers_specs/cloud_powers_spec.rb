require 'spec_helper'
require 'dotenv'

describe CloudPowers do
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
  end

  it 'should have an Auth module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse)
  end

  it 'should have a AwsResources module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse)
  end

  it 'should have a Delegator module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse)
  end

  it 'should have a Helper module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse)
  end

  it 'should have a Synapse module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse)
  end

  it 'should have a Synapse::Pipe module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse::Pipe)
  end

  it 'should have a Synapse::Queue module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse::Queue)
  end

  it 'should have a Storage module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse)
  end

  it 'has a version number' do
    expect(CloudPowers::VERSION).not_to be nil
  end
end
