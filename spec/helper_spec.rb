require 'spec_helper'
require 'dotenv'
Dotenv.load('/Users/adam/code/cloud_powers/spec/.test.env')
require_relative '../lib/cloud_powers/helper'

describe 'Helper' do
  include Smash::CloudPowers::Helper

  before(:all) do
    @original = 'This should be_fixed'
  end

  it 'should have access to the environment variables' do
    expect(env('testing')).to be_truthy # if we're running the test suite, this should be set
  end

  it 'should be have a logger' do
    expect(logger).to be_kind_of Logger
  end

  it 'should be able to format an error message' do
    begin
      1 / 0
    rescue Exception => e
      expect(format_error_message(e)).to be_kind_of String
    end
  end

  it 'should have retry logic' do
    running = Time.now.to_i
    breakout = running * 2
    test = Proc.new { running > breakout }
    smart_retry(test, 10) do
      expect(running).to be < breakout
      running += (breakout / 7)
    end
    expect(running).to be > breakout
  end

  it 'should be able to find the path for a task in the project' do
    test_file_name = 'testinz.rb'
    test_path = "#{Pathname.new(__FILE__).parent.dirname}/lib/tasks/#{test_file_name}"
    testing_task_path = Pathname.new(test_path)
    expect(testing_task_path).to eql(task_path(test_file_name))
  end

  it 'should be able to find the path for tasks in the project' do
    testing_task_path = Pathname.new("#{Pathname.new(__FILE__).parent.dirname}/lib/tasks")
    expect(testing_task_path).to eql(task_path)
  end

  it 'should be able to find the path to use in a `require_relative` call' do
    testing_task_path = Pathname.new("#{Pathname.new(__FILE__).parent.dirname}/lib/tasks/testinz")
    expect(testing_task_path).to eql(task_require_path('testinz.rb'))
  end

  it 'should be able to change a variable into camel case' do
    expect(to_camel(@original)).to be_eql('thisShouldBeFixed')
  end

  it 'should be able to change a variable into an instance variable name' do
    expect(to_i_var(@original)).to be_eql('@this_should_be_fixed')
  end

  it 'should be able to change a variable into pascal case' do
    expect(to_pascal(@original)).to be_eql('ThisShouldBeFixed')
  end

  it 'should be able to change a variable into a ruby file name' do
    expect(to_ruby_file_name(@original)).to be_eql('this_should_be_fixed.rb')
  end

  it 'should be able to change a variable into snake case' do
    expect(to_snake(@original)).to be_eql('this_should_be_fixed')
  end

  it 'should provide a valid default update message body' do
  end
end
