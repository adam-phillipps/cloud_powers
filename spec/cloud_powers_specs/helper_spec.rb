require 'spec_helper'
require 'dotenv'

describe 'Helper' do
  include Smash::Helpers
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
  end

  it '#availabe_resources should be able to provide an Array of all CloudPowers resources' do
    expect(available_resources.count).to be > 1
    expect(available_resources).to include(:Helpers)
  end

  it '#create_logger should return a logger' do
    expect(logger).to be_kind_of Logger
  end

  it '#deep_modify_keys_with should be able to modify all keys' do
    pre = { 'foo' => 'v1', 'bar' => { fleep: { 'florp' => 'yo' } } }
    actual = deep_modify_keys_with(pre) { |key| key.to_sym }
    expect(actual).to eql({ foo: 'v1', bar: { fleep: { florp: 'yo' } } })
  end

  it '#format_error_message should be able to format an error message' do
    begin
      1 / 0
    rescue Exception => e
      expect(format_error_message(e)).to be_kind_of String
    end
  end

  it '#modify_keys_with should be able to modify all first-level keys' do
    pre = { 'foo' => 'v1', 'bar' => { 'fleep' => { 'florp' => 'yo' } } }
    actual = modify_keys_with(pre) { |key| key.to_sym }
    expect(actual).to eql({ foo: 'v1', bar: { 'fleep' => { 'florp' => 'yo' } } })
  end

  it '#smart_retry should have retry logic' do
    running = Time.now.to_i
    breakout = running * 2
    test = Proc.new { running > breakout }
    smart_retry(test, 10) do
      expect(running).to be < breakout
      running += (breakout / 7)
    end
    expect(running).to be > breakout
  end

  context('paths and files') do
    before(:all) do
      @test_file_name = 'testinz.rb'
      @testing_task_path = Pathname.new(FileUtils.mkdir_p("#{project_root}/lib/tasks").first).to_s
      @testing_task_path_with_file = @testing_task_path + '/' + @test_file_name
      FileUtils.touch @testing_task_path_with_file
    end

    it '#tast_path should be able to find the path for a task in the project' do
      expect(task_path(@test_file_name)).to eql(@testing_task_path_with_file)
    end

    it '#task_path should be able to find the path for tasks in the project' do
      expect(task_path).to eql(@testing_task_path)
    end

    it '#task_require_path should be able to find the path to use in a `require_relative` call' do
      sans_ext_name = @testing_task_path_with_file.gsub(/\..*$/, '')
      expect(task_require_path(@test_file_name)).to eql(sans_ext_name)
    end

    it '#task_exist? should be able to determine when a file does exist' do
      expect(task_exist?(@test_file_name)).to be true
    end

    it '#task_exist? should be able to determine when a file does not exist' do
      expect(task_exist?('not_a_thingz.xyz')).to be false
    end

    after(:all) do
      FileUtils.rm(@testing_task_path_with_file)
    end
  end

  context('string manipulation') do
    let(:original) { 'This should be_fixed' }

    it '#to_camel should be able to change a variable into camel case' do
      expect(to_camel(original)).to be_eql('thisShouldBeFixed')
    end

    it '#to_hyph should be able to change a variable into a hyphen-delimited name' do
      expect(to_hyph(original)).to be_eql('this-should-be-fixed')
    end

    it '#to_hyph should be able to remove starting non-word characthers' do
      expect(to_hyph("@#{original}")).to be_eql('this-should-be-fixed')
    end

    it '#to_i_var should be able to change a variable into an instance variable name' do
      expect(to_i_var(original)).to be_eql('@this_should_be_fixed')
    end

    it '#to_pascal should be able to change a variable into pascal case' do
      expect(to_pascal(original)).to be_eql('ThisShouldBeFixed')
    end

    it '#to_ruby_file_name should be able to change a variable into a ruby file name' do
      expect(to_ruby_file_name(original)).to be_eql('this_should_be_fixed.rb')
    end

    it '#to_snake should be able to change a variable into snake case' do
      expect(to_snake(original)).to be_eql('this_should_be_fixed')
    end
  end
end
