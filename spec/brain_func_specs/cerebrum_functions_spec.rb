require 'spec_helper'

describe 'Shared Cerebrum Functions' do
  include Smash::BrainFunc::CerebrumFunctions
   # simple testing class
  class Jorb
    include Smash::BrainFunc::CerebrumFunctions
    include Smash::BrainFunc::WorkflowFactory
  end
  class Exp < Jorb
    # include Smash::BrainFunc::WorkflowFactory
    # include Smash::BrainFunc::CerebrumFunctions
    def initialize(*args); end
    def self.create(description)
      t = new
      t.inject_workflow(description)
      t
    end
    def build; end
    def run;  end
    def post_results; end
    def next!
      public_send "#{current_state.events.first.first}!"
    end
  end

  let(:context) { Smash::BrainFunc::Context.new('task' => 'test') }
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
  let(:exp) { Exp.new }

  it '#create_message() should be able to add a workflow' do
    message = create_message(workflow_description)
    expect(message).to eq(workflow_description.to_json)
  end

  it '#create_message() should be able to add multiple descriptions' do
    message = create_message(workflow_description, context.to_h)
    final = context.to_h.merge(workflow_description).to_json
    expect(JSON.parse(message)).to eq(JSON.parse(final))
  end

  it '#build_context() should be able to build the Context' do
    build_context(context)
    expect(verify_context_built(context)).to be true
  end

  it '#verify_context_built() should be able to verify a successful build' do
    fail
  end

  it '#verify_context_built() should be able to verify that a build was unsuccessful' do
    fail
  end

  it '#sitrep_message() should generate a valid sitrep message' do
    message = sitrep_message
    blank_sitrep = {:instanceId=>"none-aquired", :type=>"SitRep", :content=>"Unk", :extraInfo=>{}}
    expect(message).to eq blank_sitrep
  end

  it '#populate_neuron_backlog() should add the given messages to a Queue' do
    fail
  end

  it "#state() should show the current state's name" do
    job = Job.new
    job.inject_workflow(workflow_description)
    expect(job.state).to eq(:new)
  end

  it '#next!() should provide very simple, A.K.A default workflow progression' do
    fail
  end

  it '#next!() should return `:unk` if no workflow is available' do
    expect(Smash::BrainFunc::CerebrumFunctions.state).to eq(:unk)
  end

  it '#create() should inject a workflow if one is given' do
    fail
  end

  it '#create() should inject a default workflow if none is given' do
    fail
  end
end
