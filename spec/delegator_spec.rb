require 'spec_helper'
require_relative '../lib/cloud_powers'

describe 'Delegator' do
  it 'should build a default Task if no Task is found' do
    test_task = Delegator.build('abc-123', { body: {} }.to_json)

    expec(test_task.kind_of? Task).to be_true
  end

  it '#approved_task? should return true if the task is in the approved list' do
    expect(Delegator.approved_task?('Demo')).to be_true
  end

  it '#approved_task? should return false if the task is NOT in the approved list' do
    expect(Delegator.approved_task?('fakaroo')).to be_true
  end
end
