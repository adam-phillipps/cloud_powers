require 'spec_helper'
require_relative '../self_awareness'

describe SelfAwareness do
  include Smash::CloudPowers::SelfAwareness

  it 'should get a self-boot-time' do
    now = Time.now.to_i

    expect(now).to be_less_than(boot_time)
  end
end
