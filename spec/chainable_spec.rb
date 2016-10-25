require 'spec_helper'

describe Mores::Chainable do
  let(:wizard) {
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
        wizard.class_eval do
          def lightning(enemy)
            @mp >= 24 ? "wizard zapped #{enemy}!" : super
          end
        end
      end

      context 'broken' do
        let(:mp) { 50 }
        it { is_expected.to eql "wizard zapped #{enemy}!" }
      end

      context 'unbroken' do
        it { is_expected.to eql unbroken_value }
      end
    end

  end

  context 'unchained' do
    subject { wizard.new(mp).lightning enemy }
    include_examples 'all'
  end

  context 'unchained with default' do
    before do
      wizard.class_eval do
        chain(:lightning) { |enemy| "#{enemy} unscathed..." }
      end
    end
    subject { wizard.new(mp).lightning enemy }
    include_examples 'all' do
      let(:unbroken_value) { "#{enemy} unscathed..." }
    end
  end

  context 'chained' do
    let(:warlock) {
      Class.new do
        def lightning(enemy)
          "warlock zapped #{enemy}!"
        end
      end
    }
    subject { (wizard.new(mp) ** warlock.new).lightning enemy }
    include_examples 'all' do
      let(:unbroken_value) { "warlock zapped #{enemy}!" }
    end
  end

  context 'with super class' do
    let(:solmyr) { Class.new(wizard) }
    subject { solmyr.new(mp).lightning enemy }
    include_examples 'all'

    context 'with altered default' do
      before do
        solmyr.class_eval do
          chain(:lightning) { |enemy| 'y u no zap?' }
        end
      end
      include_examples 'all' do
        let(:unbroken_value) { 'y u no zap?' }
      end
      it 'separates defaults' do
        wizard; solmyr
        expect(wizard.new(mp).lightning).to be_nil
      end
    end
  end

  context 'with divergent class' do
    let(:warlock) {
      Class.new.class_exec described_class do |described_class|
        include described_class
        chain(:lightning) { 'y u no zap?' }
      self end
    }
    it 'separates defaults' do
      warlock; wizard
      expect(warlock.new.lightning).to eql 'y u no zap?'
    end
  end
end
