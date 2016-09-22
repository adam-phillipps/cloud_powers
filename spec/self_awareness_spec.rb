require 'spec_helper'
require_relative '../self_awareness'

describe NeuronMetada do
  include Smash::CloudPowers::SelfAwareness

  it 'should convert non-ruby vars into ruby naming convention' do
    start = 'fake-var'
    new_var = SelfAwareness.rubyize(start)
    expect(new_var).to eq('fake_var')
  end
end
