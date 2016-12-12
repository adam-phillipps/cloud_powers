require 'spec_helper'

describe 'AwsStubs' do
  include Smash::CloudPowers::AwsStubs

  it '#queue_stub should be able to let the user override the message body' do
    config = Smash::CloudPowers::AwsStubs.queue_stub(body: {'sneed'=>'thorn'}.to_json)
    actual = { 'sneed' => 'thorn' }.to_json
    res = config[:stub_responses][:receive_message][:messages].first[:body]
    expect(res).to eql(actual)
  end
end
