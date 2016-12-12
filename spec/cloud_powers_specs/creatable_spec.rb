require 'spec_helper'
require 'cloud_powers/stubs/aws_stubs'

describe 'Creatable' do
  before(:all) do
    @name = 'test'
  end

  class A
    include Smash::CloudPowers::Creatable
    attr_accessor :client
    attr_accessor :saved
    def initialize(**config)
      @client = config[:client]
      self
    end
    def create_resource
      self
    end
  end

  it '#build() should be able to create a new instance' do
    expect(A.build(name: 'test')).to be_kind_of(A)
  end

  it '#build() should be able to run a block of code on the new instance it created' do
    a = A.build(name: @name, client: 'some client') do |me|
      expect(me.client).to eq('some client')
      me.client = 'hey it changed'
    end

    expect(a.client).to eq('hey it changed')
  end

  it '#create() should be able to build and save an object' do
    expect(A.new.saved?).not_to be true
    a = A.create!(name: 'test')
    expect(a).to be_kind_of(A)
    expect(a.saved?).to be true
  end

  it '#create!() should be able to run a block on the ' do
    a = A.create!(name: @name, client: 'some client') do |me|
      expect(me.saved?).to be true
      me.saved = false
    end
    expect(a.saved?).to be false
  end
end
