require 'spec_helper'
require 'dotenv'


describe 'Delegator' do
  include Smash::BrainFunc::Delegator
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
    FileUtils::mkdir_p task_path
    FileUtils::touch(task_path('testinz.rb'))
    class Task; end
    class Testinz < Task; def initialize(*args); end; def self.create(*args); new; end; end
    @message = OpenStruct.new(body: { task: 'testinz' }.to_json)
  end

  it 'should build a default Task if no Task is found' do
    test_task = build_resource('abcd-1234', @message)
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
