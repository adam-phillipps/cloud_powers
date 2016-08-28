require 'spec_helper'
require_relative '../neuron_metadata'

describe NeuronMetada do
  include Smash::CloudPowers::NeuronMetada

  it 'should convert non-ruby vars into ruby naming convention' do
    start = 'fake-var'
    new_var = NeuronMetada.rubyize(start)
    expect(new_var).to eq('fake_var')
  end
end
