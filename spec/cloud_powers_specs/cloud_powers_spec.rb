require 'spec_helper'

describe CloudPowers do
  it 'should have an Auth module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Auth)
  end

  it 'should have a AwsResources module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::AwsResources)
  end

  it 'should have a Helper module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::Helpers)
  end

  it 'should have a Node module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Node)
  end

  it 'should have a SelfAwareness module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::SelfAwareness)
  end

  it 'should have a Storage module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Storage)
  end

  it 'should have a Synapse::Broadcast module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse::Broadcast)
  end

  it 'should have a Synapse::Pipe module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse::Pipe)
  end

  it 'should have a Synapse::Queue module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::Synapse::Queue)
  end

  it 'has a version number' do
    expect(CloudPowers::VERSION).not_to be nil
  end
end
