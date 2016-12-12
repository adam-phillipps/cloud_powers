require 'spec_helper'
require 'dotenv'


describe 'Delegator' do
  include Smash::BrainFunc::Delegator
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
    FileUtils::mkdir_p job_path
    FileUtils::touch(job_path('testinz.rb'))
    class Smash::Job
      def initialize(*args); end
    end
    class Smash::Testinz < Smash::Job
      def initialize(*args); end
      def self.create!(*args); new(*args); end
    end
  end

  let(:message) { OpenStruct.new(body: { job: 'testinz' }.to_json) }
  let(:bad_job_message) { OpenStruct.new(body: { job: 'snedbedular2' }.to_json) }

  it 'should build a default Job if no Job is found' do
    test_job = build_job('abcd-1234', bad_job_message)
    expect(test_job).to be_kind_of Smash::Job
  end

  it 'should build a real job if it is approved' do
    test_job = build_job('abcd-1234', message)
    expect(test_job).to be_kind_of Smash::Job
  end

  it 'should be able to determine if the Job is in the approved list' do
    expect(approved_job?('testinz')).to be true
  end

  it 'should be able to determine if the Job is NOT in the approved list' do
    expect(approved_job?('fake-aroo')).to be false
  end

  after(:all) do
    FileUtils::rm_rf(job_path)
  end
end
