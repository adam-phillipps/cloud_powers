require 'spec_helper'

describe 'Smash::CloudPowers::Context' do
  include Smash::CloudPowers::Helper
  include Smash::CloudPowers::Zenv

  before(:all) do
    Dotenv.load("#{project_root}/.test.env")
  end

  before(:each) do
    @vanilla_config_hash = {
      task: ['demo'],
      queue: ['backlog', 'sned'],
      pipe: ['status_stream']
    }
    @vanilla_config_arr = [:task, 'demo', :queue, 'backlog', 'sned', :pipe, 'status_stream']
    @vanilla_2d_arr = [[:task, 'demo'], [:queue, 'backlog', 'sned'], [:pipe, 'status_stream']]
    @vanilla_json = "{\"task\":[\"demo\"],\"queue\":[\"backlog\",\"sned\"],\"pipe\":[\"status_stream\"]}"
    @vanilla_context = Smash::CloudPowers::Context.new('task' => 'test')
  end

  context 'Enumerable validation' do
    let(:arr) { @vanilla_config_arr }
    let(:two_d_arr) { @vanilla_2d_arr }
    let(:invalid_arr) { arr[0] = :foo; arr }

    it 'should be able to take an Array for #new()' do
      context = Smash::CloudPowers::Context.new(arr)
      expect(context.structure).to eql(@vanilla_config_hash)
    end

    it 'should be able to take a 2D Array for #new()' do
      context = Smash::CloudPowers::Context.new(two_d_arr)
      expect(context.structure).to eql(@vanilla_config_hash)
    end

    it 'should be able to validate a well formatted Array' do
      expect(@vanilla_context.valid_array_format?(arr)).to be true
    end

    it 'should be able to validate a poorly formatted Array' do
      expect(@vanilla_context.valid_array_format?(invalid_arr)).to be false
    end
  end

  context 'Hash validation' do
    let(:config_hash) { @vanilla_config_hash }
    let(:invalid_config_hash) do
        {
        foo: 'demo',
        bard: [:backlog, :sned],
        config: :status_stream
      }
    end

    it 'should be able to take a Hash for #new()' do
      context = Smash::CloudPowers::Context.new(config_hash)
      expect(context.package).to eql(config_hash)
    end

    it 'should be able to validate a well formatted Hash' do
      hash_is_valid = @vanilla_context.valid_hash_format?(config_hash)
      expect(hash_is_valid).to be true
    end

    it 'should be able to validate a poorly formatted Hash' do
      hash_is_valid = @vanilla_context.valid_hash_format?(invalid_config_hash)
      expect(hash_is_valid).to be false
    end
  end

  context 'JSON validation' do
    let(:json) { @vanilla_json }
    let(:invalid_json) { "{\"foo\":[\"demo\"],\"queue\":[\"backlog\",\"sned\"],\"pipe\":[\"status_stream\"]}" }

    it 'should be able to take JSON for #new()' do
      context = Smash::CloudPowers::Context.new(json)
      expect(context.to_json).to eql(JSON.parse(json).to_json)
    end

    it 'should be able to validate a well formatted JSON string' do
      hash_is_valid = @vanilla_context.valid_json_format?(json)
      expect(hash_is_valid).to be true
    end

    it 'should be able to validate a poorly formatted JSON string' do
      hash_is_valid = @vanilla_context.valid_json_format?(invalid_json)
      expect(hash_is_valid).to be false
    end
  end

  context 'translations' do
    it 'should be able to translate a flattened Array into a valid structure' do
      context = Smash::CloudPowers::Context.new(@vanilla_config_arr)
      expect(context.structure).to be_kind_of Hash
    end

    it 'should be able to translate a 2D Array into a valid structure' do
      context = Smash::CloudPowers::Context.new(@vanilla_2d_arr)
      expect(context.structure).to be_kind_of Hash
    end
  end

  context 'serializing' do
    it 'should be able to serialize its resources into JSON' do
      context = Smash::CloudPowers::Context.new(@vanilla_config_hash)
      expect(context.to_json).to eql(@vanilla_config_hash.to_json)
    end

    it 'should be able to parse JSON into a valid Context' do
      context = Smash::CloudPowers::Context.new(@vanilla_json)
      expect(context.structure).to eql(@vanilla_config_hash)
    end
  end
end
