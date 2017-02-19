require 'spec_helper'
require 'tempfile'

describe Mores::Patch::FileUtils do
  using described_class

  describe '::compare_stream' do
    let(:data) { Random.new.tap { |r| break r.bytes r.rand 0x40..0x40000 } }
    let(:file) { Tempfile.new File.basename(__FILE__, '.rb') }
    before { file.write data; file.rewind }
    after { file.delete }

    subject { compare_stream.call *[file, StringIO.new(data)].shuffle! }

    context 'when not refined' do
      let(:compare_stream) { FileUtils.method(:compare_stream) }
      it('still needs a patch to work correctly') { is_expected.to be false }
    end

    context 'when refined' do
      let(:compare_stream) { -> *_ { FileUtils.compare_stream(*_) } }
      it { is_expected.to be true }
      it 'uses stream blksize' do
        expect(file).to receive(:read).with(file.stat.blksize, anything).at_least(:once).and_call_original
        subject
      end
      [nil, 0].each do |blksize|
        it "uses 1024 if stream blksize is #{blksize || 'nil'}" do
          allow(file).to receive(:stat).and_return(double blksize: blksize)
          expect(file).to receive(:read).with(1024, anything).at_least(:once).and_call_original
          subject
        end
      end

      context 'when different' do
        before { rand(0..data.length).tap { |p| data[p] = data[p].next } }
        it { is_expected.to be false }
      end
    end
  end
end
