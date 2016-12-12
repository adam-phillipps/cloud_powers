require 'spec_helper'

describe 'Storage' do
  extend Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::Helpers
  include Smash::CloudPowers::Storage
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    s3(Smash::CloudPowers::AwsStubs.storage_stub)
    @test_file = 'testinz.rb'
    @test_job_path = job_path(@test_file)
    FileUtils.touch @test_job_path
  end

  context 'local files' do
    it '#local_job_file_exists?() should be able to determine if a file exists in the job dir' do
      expect(local_job_file_exists?(@test_file)).to be true
    end

    it '#source_job() should be able to use a local file first, if it exists' do
      expect(local_job_file_exists?('filedoesnotexistsixetonseodelif')).to be false
    end
  end

  context 'in remote storage' do
    it '#search() should be able to use Regex to match the name of the file' do
      pending 'need to add stubbing'
      expect(search(zfind('job_storage'), %r[.*])).not_to be_empty
    end

    it '#search() should be able to use a String to match the name of the file' do
      pending 'need to add stubbing'
      expect(search(zfind('job_storage'), @test_file)).not_to be_empty
    end

    it '#search() should be able to return negative results with an empty Array' do
      expect(search(zfind('job_storage'), 'zned')).to be_empty
    end

    it '#source_job() to be able to force getting a file from remote storage' do
      FileUtils.touch(@testfile) unless local_job_file_exists?(@test_file)
      before_time = File.mtime(@test_job_path)

      source_job(@test_file)
      after_time = Time.now

      expect(File.mtime(@test_job_path)).to be <= after_time
      FileUtils.rm @test_job_path
    end
  end

  after(:all) do
    FileUtils.rm @test_job_path if  local_job_file_exists?(@test_job_path)
  end
end
