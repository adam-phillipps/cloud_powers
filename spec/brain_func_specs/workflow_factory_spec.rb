require 'spec_helper'
require 'cloud_powers/stubs/aws_stubs'

describe 'WorkflowFactory' do
  include Smash::BrainFunc::WorkflowFactory
  extend Smash::CloudPowers::AwsStubs
  include Smash::CloudPowers::Zenv
  include Workflow

  # simple testing class
  class Job
    include Smash::BrainFunc::WorkflowFactory
    def initialize(*args); end
    def self.create(description)
      t = new
      t.inject_workflow(description)
      t
    end
    def build; end
    def run;  end
    def post_results; end
    def build_two; end
    def next!
      public_send "#{current_state.events.first.first}!"
    end
  end

  let(:description) do
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

  let(:description_two) do
    {
      workflow: {
        states: [
          { new: { event: :build_two, transitions_to: :done } },
          { done: nil }
        ]
      }
    }
  end

  it 'should be able to inject a workflow on an object' do
    t = Job.new
    t.inject_workflow(description)
    expect(t.has_workflow?).to be true
  end

  it 'should be instance specific' do
    t = Job.create(description_two)
    expect(t.done?).to be false
    t.build_two!
    expect(t.done?).to be true
  end

  context('state awareness') do
    let(:job) { Job.create(description) }

    it 'should be able to answer if it is in a certain state' do
      expect(job.new?).to be true
    end

    it 'should be able to answer if it is not in a certain state' do
      expect(job.done?).to be false
    end
  end

  context('state progression') do
    let(:job) { Job.create(description) }

    it 'should be able to move from a state to the next, on demand' do
      expect(job.new?).to be true
      job.next!
      expect(job.building?).to be true
    end
  end
end
