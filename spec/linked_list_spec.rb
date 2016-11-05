require 'spec_helper'

describe Mores::LinkedList do
  subject(:list) { described_class.new }

  def nodes_from_head
    nodes = []
    n = list.head; until n.nil?; nodes << n; n = n.next; end
    nodes
  end
  def nodes_from_tail
    nodes = []
    n = list.tail; until n.nil?; nodes << n; n = n.prev; end
    nodes
  end

  shared_examples_for 'empty' do
    it { is_expected.to have_attributes(
      length: 0,
      size: 0,
      count: 0,
      empty?: true,
      head: nil,
      tail: nil
    )}
  end

  shared_examples_for 'non-empty' do |values|
    it { is_expected.to have_attributes(
      length: values.length,
      size: values.length,
      count: values.length,
      empty?: false
    )}
    it { expect(nodes_from_head.map &:value).to eql values }
    it { expect(nodes_from_tail.map &:value).to eql values.reverse }
  end

  shared_examples_for 'enumerator' do |method, opts = {}|
    before { values.each &list.method(:>>) }
    let!(:nodes) { nodes_from_head } if opts[:deletes?]
    let(:block) { -> x { } }
    let(:values_after) { values }

    shared_examples_for 'with block' do
      it { is_expected.to be list }
      it { expect(nodes_from_head.map &:value).to eql values_after }
      include_examples 'deletion' if opts[:deletes?]
    end

    context 'without block' do
      subject(:result) { list.public_send method }
      it { is_expected.to be_an Enumerator }
      its(:size) { is_expected.to eql enumerates.length }
      its(:to_a) { is_expected.to eql enumerates }

      context 'when chained with block' do
        subject! { result.each &block }
        include_examples 'with block'
      end
    end

    context 'with block' do
      subject! { list.public_send(method, &block) }
      include_examples 'with block'
    end
  end

  shared_examples_for 'deletion' do
    it 'clears deleted nodes' do
      expect(nodes - nodes_from_head).to be_any
        .and all have_attributes(list: nil, prev: nil, next: nil)
    end
  end

  describe 'new' do
    include_examples 'empty'
  end

  describe 'add to head' do
    before { list << 2 << 4 << 6 }
    include_examples 'non-empty', [6, 4, 2]
  end

  describe 'add to tail' do
    before { list >> 2 >> 4 >> 6 }
    include_examples 'non-empty', [2, 4, 6]
  end

  describe 'add to left' do
    before {
      list << 'a'
      list.head < 'd'
      list.tail < 'c' < 'b'
    }
    include_examples 'non-empty', %w[d c b a]
  end

  describe 'add to right' do
    before {
      list >> :a
      list.tail > :d
      list.head > :c > :b
    }
    include_examples 'non-empty', %i[a b c d]
  end

  describe 'each' do
    include_examples 'enumerator', :each do
      let(:values) { [1, :a, false] }
      let(:enumerates) { values }
    end
  end

  describe 'reverse_each' do
    include_examples 'enumerator', :reverse_each do
      let(:values) { [2, :b, nil] }
      let(:enumerates) { values.reverse }
    end
  end

  describe 'each_node' do
    include_examples 'enumerator', :each_node do
      let(:values) { [:c, 3, 'p', :o] }
      let(:enumerates) { nodes_from_head }
    end
  end

  describe 'reverse_each_node' do
    include_examples 'enumerator', :reverse_each_node do
      let(:values) { [:r2, 'd2'] }
      let(:enumerates) { nodes_from_tail }
    end
  end

  describe 'modify value' do
    before {
      list >> :A
      list.head.value = :Z
    }
    its(:'head.value') { is_expected.to eql :Z }
  end

  describe 'delete' do
    before { [:a, 1, :b, 2, nil, 3, :c].each &list.method(:>>) }
    let!(:nodes) { nodes_from_head }

    context 'by node' do
      let!(:result) {
        %w[head tail head.next].map { |node| list.instance_eval(node).delete }
      }

      it 'returns deleted value' do
        expect(result).to eql [:a, :c, :b]
      end
      include_examples 'non-empty', [1, 2, nil, 3]
      include_examples 'deletion'
    end

    context 'by value' do
      shared_examples_for 'matched' do |matched_values|
        it { expect(result).to eql matched_values.last }
        include_examples 'non-empty', [:a, 1, :b, 2, nil, 3, :c] - matched_values
        include_examples 'deletion'
      end

      shared_examples_for 'unmatched' do |unmatched_value|
        it { expect(result).to eql unmatched_value }
      end

      let!(:result) { list.delete value }
      context 'when matched' do
        let(:value) { BasicObject.new.instance_eval { def ==(x) x.is_a? Integer end; self } }
        include_examples 'matched', [1, 2, 3]
      end
      context 'when not matched' do
        let(:value) { 99 }
        include_examples 'unmatched', nil
      end

      context 'with block' do
        let!(:result) { list.delete value, &block }
        context 'when matched' do
          let(:value) { nil }
          let(:block) { -> x { fail 'should not be called' } }
          include_examples 'matched', [nil]
        end
        context 'when not matched' do
          let(:value) { 7 }
          let(:block) { -> x { "no #{x}!" } }
          include_examples 'unmatched', 'no 7!'
        end
      end
    end
  end

  describe 'delete_if' do
    include_examples 'enumerator', :delete_if, deletes?: true do
      let(:values) { [:a, 1, :b, 2, :c] }
      let(:enumerates) { values }
      let(:block) { -> x { x.is_a? Symbol } }
      let(:values_after) { [1, 2] }
    end
  end

  describe 'clear' do
    before { [1, 2, 3].each &list.method(:>>) }
    let!(:nodes) { nodes_from_head }
    let!(:result) { list.clear }

    it 'returns self' do
      expect(result).to be list
    end
    include_examples 'empty'
    include_examples 'deletion'
  end

  describe 'count' do
    before { [:a, 7, :b, 7, :c, 7, :d].each &list.method(:>>) }
    context 'all' do
      after { list.count }
      it { is_expected.not_to receive :each }
    end
    context 'by value' do
      subject { list.count 7 }
      it { is_expected.to eql 3 }
    end
    context 'by predicate' do
      subject { list.count { |x| x.is_a? Symbol } }
      it { is_expected.to eql 4 }
    end
  end
end
