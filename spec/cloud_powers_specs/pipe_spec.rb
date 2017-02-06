require 'spec_helper'

describe 'Pipe' do
  extend Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::Synapse::Pipe
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
    kinesis(
      Smash::CloudPowers::AwsStubs.pipe_stub(
        name: 'test', sequence_number: '1234'
      )
    )
  end

  it '#create_stream() should be able to create a Pipe' do
    expect(create_stream(name: 'test')).to be_kind_of Smash::CloudPowers::Synapse::Pipe::Stream
  end

  it '#pipe_to() should be able to send a single message through the Pipe' do
    res = pipe_to(:test_stream) do
      { foo: 'bar' }.to_json
    end
    expect(res).to eql '1234'
  end

  it '#stream_exists?() should be able to check to see if a Pipe exists' do
    expect(stream_exists?(:test_stream)).to be true
  end

  it '#stream_status() should be able to check the status for a Pipe' do
    expect(pipe_status(:test_stream)).to eql 'ACTIVE'
  end
end
