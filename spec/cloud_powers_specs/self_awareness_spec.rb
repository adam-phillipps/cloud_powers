require 'spec_helper'
require_relative '../../lib/stubs/aws_stubs'


describe 'SelfAwareness module' do
  include Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::SelfAwareness
  extend Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    @config = Smash::CloudPowers::AwsStubs.node_stub.merge(max_count: 5)
  end

  context '#get_awareness!' do
    before(:each) do
      ec2(@config)
      get_awareness!
    end

    it 'should get a self-boot-time' do
      future = Time.now.to_i + 30 # 30 seconds from now
      expect(future).to be > boot_time
    end

    it 'should get the public host as the "@public_hostname"' do
      is_valid_url = !("http://#{@public_hostname}" =~ URI::regexp).nil?
      expect(is_valid_url).to be true
    end

    it '#tag_search() should be able to find a tag on a given instance' do
      expect(tag_search('task')).to eq('test')
    end
  end
end