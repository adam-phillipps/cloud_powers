require 'spec_helper'
require 'dotenv'

describe 'Zenv' do
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
  end

  it 'should be able to search the system environment' do
    expect(system_vars('USER')).to be_kind_of String
  end

  it 'should be able to use the .env file' do
    expect(env_vars('TESTING')).to be_truthy
  end

  it 'should be able to return nil for any unfound variable' do
    expect(zfind('prolly-not-a-thing')).to be_nil
  end

  it 'should be able to find a variable from any set' do
    expect(zfind('testing')).to be_truthy
    expect(zfind('USER')).to be_kind_of String
  end
end
