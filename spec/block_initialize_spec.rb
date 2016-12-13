require 'spec_helper'

describe Mores::BlockInitialize do
  let(:klass) {
    Class.new.class_exec(described_class) do |described_class|
      def calls; @calls ||= []; end
      extend described_class
      def initialize(*args, &block)
        calls << ['initialize', args: args, block: block]
      end
    self; end
  }
  let(:args) { (1..10).to_a.sample rand(0..2) }
  subject { klass.new *args, &block }

  context 'with no block' do
    let(:block) { nil }
    its(:calls) { is_expected.to eql [
      ['initialize', args: args, block: nil ]
    ]}
  end

  context 'with parameterless block' do
    let(:block) { -> {
      calls << ['block', context: self]
    } }
    its(:calls) { is_expected.to eql [
      ['initialize', args: args, block: nil ],
      ['block', context: subject]
    ]}
  end

  context 'with single-parameter block' do
    let(:block) { -> x {
      x.calls << ['block', context: self, arg: x]
    } }
    its(:calls) { is_expected.to eql [
      ['initialize', args: args, block: nil ],
      ['block', context: self, arg: subject]
    ]}
  end

  context 'with other block' do
    let(:block) { -> x, y {
      x.calls << ['block', context: self, args: [x, y]]
    } }
    its(:calls) { is_expected.to eql [
      ['initialize', args: args, block: block ]
    ]}
  end
end
