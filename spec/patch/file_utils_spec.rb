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

  describe '::safe_write' do
    let(:dir) { Dir.mktmpdir + '/' }
    after { FileUtils.remove_entry dir }

    let(:existing_entries) { %w[replays/ pwnage.TvT pwnage noobage.PvZ] }
    let(:existing_data) { 'We require more minerals.' }
    let(:new_data) { 'My life for Aiur!' }

    before {
      existing_entries.each do |e|
        e.end_with?('/') \
          ? Dir.mkdir(dir + e)
          : File.write(dir + e, existing_data)
      end
    }

    after {
      existing_entries.each do |e|
        e.end_with?('/') \
          ? expect(Dir).to(exist dir + e)
          : expect(File.read dir + e).to(eql existing_data)
      end
    }


    shared_examples 'all' do
      def verify_write(to:)
        expect(subject).to eql [result_dir + to, new_data.bytesize]
        expect(File).to exist dir + to
        expect(File.read dir + to).to eql new_data
      end

      context 'when file does not exist' do
        let(:filename) { 'pwnage.ZvP' }
        it('writes to filename') { verify_write to: 'pwnage.ZvP' }
      end

      context 'when file exists' do
        let(:existing_entries) { super().push *%w[pwnage.ZvP] }
        let(:filename) { 'pwnage.ZvP' }

        it('writes to next filename') { verify_write to: 'pwnage_0.ZvP' }
      end

      context 'when multiple files exist' do
        let(:existing_entries) { super().push *%w[pwnage.ZvP pwnage_0.ZvP/ pwnage_3.ZvP] }
        let(:filename) { 'pwnage.ZvP' }

        it('writes to next filename') { verify_write to: 'pwnage_1.ZvP' }
      end

      context 'when name ends with suffix' do
        let(:existing_entries) { super().push *%w[pwnage_2.ZvP/ pwnage_2_0.ZvP] }
        let(:filename) { 'pwnage_2.ZvP' }

        it('writes to next filename') { verify_write to: 'pwnage_2_1.ZvP' }
      end

      context 'when name is a directory' do
        let(:existing_entries) { super().push *%w[pwnage.ZvP/] }
        let(:filename) { 'pwnage.ZvP/' }

        it('fails') { expect { subject }.to raise_error Errno::EISDIR }
      end
    end

    context 'with absolute path' do
      subject { FileUtils.safe_write dir + filename, new_data }
      let(:result_dir) { dir }
      include_examples 'all'
    end

    context 'with relative path' do
      subject { Dir.chdir(dir) { FileUtils.safe_write filename, new_data } }
      let(:result_dir) { '' }
      include_examples 'all'
    end
  end
end
