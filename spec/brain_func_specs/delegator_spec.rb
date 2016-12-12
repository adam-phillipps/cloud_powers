require 'spec_helper'
require 'dotenv'


describe 'Delegator' do
  include Smash::BrainFunc::Delegator
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/spec/.test.env")
    FileUtils::mkdir_p job_path
    FileUtils::touch(job_path('testinz.rb'))
    class Smash::Job; end
    class Smash::Testinz < Smash::Job
      def initialize(*args); end
      def self.create!(*args); new(*args); end
    end
    @message = OpenStruct.new(body: { job: 'testinz' }.to_json)
  end

  it 'should build a default Job if no Job is found' do
    test_job = build_job('abcd-1234', @message)
    expect(test_job).to be_kind_of Smash::Testinz
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
