require 'spec_helper'
require 'dotenv'


describe 'SelfAwareness module' do
  include Smash::CloudPowers::SelfAwareness
  extend Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
  end

  context '#get_awareness!' do
    before(:each) do
      get_awareness!
    end

    it 'should get a self-boot-time' do
      future = Time.now.to_i + 30 # 30 seconds from now
      expect(future).to be > boot_time
    end

    it 'should get the public host as the "instance_url"' do
      is_valid_url = !(@instance_url =~ URI::regexp).nil?
      expect(is_valid_url).to be true
    end
  end
end
