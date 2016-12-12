require 'spec_helper'

describe 'BrainFunc' do
  it 'should have a Context class' do
    expect(Smash::BrainFunc.const_get(:Context)).not_to be nil
  end

  it 'should have a Delegator module' do
    expect(Smash::BrainFunc.included_modules).to include(Smash::BrainFunc::Delegator)
  end

  it 'should have a SelfAwareness module' do
    expect(Smash::BrainFunc.included_modules).to include(Smash::BrainFunc::SelfAwareness)
  end

  it 'should have a WorkflowFactory module' do
    expect(Smash::BrainFunc.included_modules).to include(Smash::BrainFunc::WorkflowFactory)
  end
end
