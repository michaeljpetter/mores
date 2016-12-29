require 'spec_helper'

describe Mores::ImmutableStruct do
  let(:name) { nil }
  let(:members) { [:rank, :kills] }
  let(:options) { {} }
  let(:struct) { described_class.new *[name].compact, *members, **options }

  let(:values) { ['Ravager', 13] }
  let(:instance) { struct[*values] }

  after { described_class.__send__ :remove_const, name rescue nil }

  shared_examples_for 'a struct' do
    subject { struct }
    it { is_expected.to be_a Class }
    its(:ancestors) { are_expected.to include ::Struct }
    its(:members) { are_expected.to eql members }

    context 'instance' do
      subject { instance }
      its(:values) { are_expected.to eql values }
    end
  end

  shared_examples_for 'immutable' do
    subject { instance }
    it { is_expected.not_to respond_to :[]= }

    it 'should not respond to member setters' do
      members.each { |x| is_expected.not_to respond_to "#{x}=" }
    end
  end

  shared_examples_for 'named' do
    subject { struct }
    it { is_expected.to be described_class.const_get(name) }
    its(:name) { is_expected.to eql "#{described_class}::#{name}" }
  end

  shared_examples_for 'not named' do
    subject { struct }
    its(:name) { is_expected.to be_nil }
  end

  shared_examples_for 'flyweight' do
    subject { instance }
    its(:clone) { is_expected.to equal subject }
  end

  shared_examples_for 'not flyweight' do
    subject { instance }
    its(:clone) { is_expected.not_to equal subject }
    its(:clone) { is_expected.to eql subject }
  end

  shared_examples_for 'strict' do
    subject { -> { instance } }
    before { values.pop }
    it { is_expected.to raise_error ArgumentError }
  end

  shared_examples_for 'not strict' do
    subject { instance }
    before { values.pop }
    its(:values) { are_expected.to eql values + [nil] }
  end

  shared_examples_for 'default options' do
    it_has_behavior 'flyweight'
    it_has_behavior 'not strict'
  end


  context 'with no arguments' do
    let(:members) { [] }
    subject { -> { struct } }
    it { is_expected.to raise_error ArgumentError }
  end

  context 'with no name' do
    it_behaves_like 'a struct'
    it_has_behavior 'immutable'
    it_behaves_like 'not named'
    include_examples 'default options'
  end

  context 'with a name' do
    let(:name) { 'UnitRank' }
    it_behaves_like 'a struct'
    it_has_behavior 'immutable'
    it_behaves_like 'named'
    include_examples 'default options'
  end

  context 'with flyweight off' do
    let(:options) { { flyweight: false } }
    it_behaves_like 'not flyweight'
  end

  context 'with strict on' do
    let(:options) { { strict: true } }
    it_behaves_like 'strict'
  end
end
