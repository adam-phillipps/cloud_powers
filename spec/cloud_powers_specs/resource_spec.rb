require 'spec_helper'
require 'cloud_powers/resource'

describe 'Smash::CloudPowers::Resource' do
  it 'should have common modules' do
    expect(Smash::CloudPowers::Resource.included_modules).to include(Smash::CloudPowers::Creatable)
    expect(Smash::CloudPowers::Resource.included_modules).to include(Smash::CloudPowers::AwsResources)
    expect(Smash::CloudPowers::Resource.included_modules).to include(Smash::CloudPowers::Helpers)
    expect(Smash::CloudPowers::Resource.included_modules).to include(Smash::CloudPowers::Zenv)
  end

  it 'should have a name attribute' do
    expect(Smash::CloudPowers::Resource.public_instance_methods(false)).to include(:name)
    expect(Smash::CloudPowers::Resource.public_instance_methods(false)).to include(:name=)
  end
end
