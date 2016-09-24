require 'spec_helper'
require 'dotenv'
require "fileutils"
require 'ostruct'
require_relative '../lib/cloud_powers'

describe 'Delegator' do
  include Smash::CloudPowers::Delegator

  before(:all) do
    FileUtils::mkdir_p task_path
    FileUtils::touch(task_path('testinz.rb'))
    class Testinz; def initialize(*args); end; end
    class Task; end
    @message = OpenStruct.new(body: { task: 'testinz' }.to_json)
  end

  before(:each) do
    Dotenv.load('/Users/adam/code/cloud_powers/spec/.test.env')
  end

  it 'should build a default Task if no Task is found' do
    test_task = build('abcd-1234', @message)
    expect(test_task.kind_of? Testinz).to be true
  end

  it 'should be able to determine if the task is in the approved list' do
    expect(approved_task?('testinz')).to be true
  end

  it 'should be able to determine if the task is NOT in the approved list' do
    expect(approved_task?('fake-aroo')).to be false
  end

  after(:all) do
    FileUtils::rm_rf(task_path)
  end
end
