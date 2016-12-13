require 'spec_helper'

describe Mores::Succession do
  let(:default) { nil }
  let(:succession) {
    described_class.new { |x| x.line :lightning, &default }
  }
  let(:enemy) { %w[Trolls Medusas Troglodytes].sample }
  let(:remaining) { rand 2..20 }
  subject { succession.lightning(enemy) { remaining } }

  shared_examples_for 'unhandled' do
    context 'without default' do
      it { is_expected.to be_nil }
    end
    context 'with default' do
      let(:default) { -> e, &r { "#{e} unscathed… (#{r.()} remain)" } }
      it { is_expected.to eql "#{enemy} unscathed… (#{remaining} remain)" }
    end
  end

  context 'empty' do
    include_examples 'unhandled'
  end

  context 'non-empty' do
    let(:wizard) {
      Class.new do
        def initialize(name, mp)
          @name = name
          @mp = mp
        end
        def lightning(enemy)
          return super if @mp < 24
          "#{@name} zapped #{enemy}! (#{yield} remain)"
        end
      end
    }
    let(:solmyr_mp) { 10 }
    let(:solmyr) { wizard.new 'Solmyr', solmyr_mp }
    let(:halon_mp) { 10 }
    let(:halon) { wizard.new 'Halon', halon_mp }

    before { succession >> solmyr >> Object.new >> halon }

    context 'unhandled' do
      include_examples 'unhandled'
    end

    context 'handled first' do
      let(:solmyr_mp) { 71 }
      before { expect(halon).not_to receive(:lightning) }
      it { is_expected.to eql "Solmyr zapped #{enemy}! (#{remaining} remain)" }
    end

    context 'handled last' do
      let(:halon_mp) { 40 }
      it { is_expected.to eql "Halon zapped #{enemy}! (#{remaining} remain)" }
    end

    context 'missing method' do
      context 'external' do
        before { expect(solmyr).not_to receive(:armageddon) }
        it { expect { succession.armageddon }.to raise_error NoMethodError }
      end
      context 'internal' do
        before { def solmyr.lightning(_) zap() end }
        before { expect(halon).not_to receive(:zap) }
        it { expect { subject }.to raise_error NoMethodError }
      end
    end
  end
end
