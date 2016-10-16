require 'spec_helper'

describe Mores::Chainable do
  let(:solmyr) {
    Class.new.class_exec described_class do |described_class|
      include described_class
      chain :lightning
      def initialize(mp)
        @mp = mp
      end
    self end
  }
  let(:mp) { 10 }
  let(:enemy) { ['troll', 'medusa'].sample }

  shared_examples_for 'all' do
    let(:unbroken_value) { nil }

    context 'not overridden' do
      it { is_expected.to eql unbroken_value }
    end

    context 'overridden' do
      before do
        solmyr.class_eval do
          def lightning(enemy)
            @mp >= 24 ? "solmyr zapped #{enemy}!" : super
          end
        end
      end

      context 'broken' do
        let(:mp) { 50 }
        it { is_expected.to eql "solmyr zapped #{enemy}!" }
      end

      context 'unbroken' do
        it { is_expected.to eql unbroken_value }
      end
    end

  end

  context 'unchained' do
    subject { solmyr.new(mp).lightning enemy }
    include_examples 'all'
  end

  context 'unchained with default' do
    before do
      solmyr.class_eval do
        chain(:lightning) { |enemy| "#{enemy} unscathed..." }
      end
    end
    subject { solmyr.new(mp).lightning enemy }
    include_examples 'all' do
      let(:unbroken_value) { "#{enemy} unscathed..." }
    end
  end

  context 'chained' do
    let(:dracon) {
      Class.new do
        def lightning(enemy)
          "dracon zapped #{enemy}!"
        end
      end
    }
    subject { (solmyr.new(mp) ** dracon.new).lightning enemy }
    include_examples 'all' do
      let(:unbroken_value) { "dracon zapped #{enemy}!" }
    end
  end
end
