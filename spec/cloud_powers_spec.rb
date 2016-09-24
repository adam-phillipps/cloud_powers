require 'spec_helper'

describe CloudPowers do
  it 'has a version number' do
    expect(CloudPowers::VERSION).not_to be nil
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

  it 'should have a SelfAwareness module' do
    expect(Smash::CloudPowers.included_modules).to include(Smash::CloudPowers::SelfAwareness)
  end
end
