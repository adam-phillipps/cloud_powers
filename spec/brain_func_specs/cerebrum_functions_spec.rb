require 'spec_helper'

describe 'Shared Cerebrum Functions' do
  include Smash::BrainFunc::CerebrumFunctions

  let(:context_description) { Smash::BrainFunc::Context.new('task' => 'test').structure }
  let(:workflow_description) do
    {
      workflow: {
        states: [
          { new: { event: :build, transitions_to: :building } },
          { building: { event: :run, transitions_to: :in_progress } },
          { in_progress: { event: :post_results, transitions_to: :done } },
          { done: nil }
        ]
      }
    }
  end

  it '#create_message should be able to add a Context' do
    byebug
    message = create_message(context_description)
    expect(JSON.parse(message['context'])).not_to be nil
  end

  it '#create_message should be able to add a workflow' do

  end

  it '#build_context should be able to build the Context' do
    fail
  end

  it '#sitrep should generate a valid sitrep message' do
    fail
  end

  it '#populate_neuron_backlog should add the given messages to a Queue' do
    fail
  end

  it "#state should show the current state's name" do
    fail
  end

  it '#next! should provide very simple, A.K.A default workflow progression' do
    fail
  end

  it '#create should inject a workflow if one is given' do
    fail
  end

  it '#create should inject a default workflow if none is given' do
    fail
  end
end
