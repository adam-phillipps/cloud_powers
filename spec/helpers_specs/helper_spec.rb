require 'spec_helper'
require 'dotenv'

describe 'Smash::CloudPowers::Helpers' do
  include Smash::CloudPowers::Helpers
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
  end

  it '#create_logger should return a logger' do
    expect(logger).to be_kind_of Logger
  end

  it '#deep_modify_keys_with should be able to modify all keys' do
    pre = { 'foo' => 'v1', 'bar' => { fleep: { 'florp' => 'yo' } } }
    actual = deep_modify_keys_with(pre) { |key| key.to_sym }
    expect(actual).to eql({ foo: 'v1', bar: { fleep: { florp: 'yo' } } })
  end

  context '#find_and_remove' do
    let(:test_hash) { {one: 1, two: 2, three: 3, four: { f: 'our' } } }

    it '#find_and_remove should be able to find a key if it exists' do
      res = find_and_remove('two', test_hash)
      expect(res).not_to include(:two)
    end

    it '#find_and_remove should be able to return nil if the key does not exist' do
      res, res_hash = find_and_remove('five', test_hash)
      expect(res).to be_nil
    end

    it '#find_and_remove should be able to the whole Hash if a key does not exist' do
      res, res_hash = find_and_remove('five', test_hash)
      expect(res_hash).to eq test_hash
    end

    it '#find_and_remove should be able to return the remainder of a Hash if the key exists' do
      res, res_hash = find_and_remove(:four, test_hash)
      expect(res_hash).to eq test_hash.reject { |k,v| k == :four }
    end
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
      @testing_job_path = Pathname.new(FileUtils.mkdir_p("#{project_root}/lib/jobs").first).to_s
      @testing_job_path_with_file = @testing_job_path + '/' + @test_file_name
      FileUtils.touch @testing_job_path_with_file
    end

    it '#job_path should be able to find the path for a job in the project' do
      expect(job_path(@test_file_name)).to eql(@testing_job_path_with_file)
    end

    it '#job_path should be able to find the path for jobs in the project' do
      expect(job_path).to eql(@testing_job_path)
    end

    it '#job_require_path should be able to find the path to use in a `require_relative` call' do
      sans_ext_name = @testing_job_path_with_file.gsub(/\..*$/, '')
      expect(job_require_path(@test_file_name)).to eql(sans_ext_name)
    end

    it '#job_exist? should be able to determine when a file does exist' do
      expect(job_exist?(@test_file_name)).to be true
    end

    it '#job_exist? should be able to determine when a file does not exist' do
      expect(job_exist?('not_a_thingz.xyz')).to be false
    end

    after(:all) do
      FileUtils.remove_dir(@testing_job_path)
    end
  end

  context('string manipulation') do
    let(:original) { 'This should be_fixed' }
    let(:test_hash) { { one: 1, two: 2, three: 3 } }
    let(:test_json) { test_hash.to_json }

    it '#from_json should be able to return a hash from valid JSON' do
      expect(from_json(test_json)).to eq JSON.parse(test_hash.to_json)
    end

    it '#from_json should be able to return nil from invalid JSON' do
      expect(from_json(original)).to be_nil
    end


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
