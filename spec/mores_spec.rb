require 'spec_helper'

describe Mores do
  it 'should have a valid version' do
    expect(described_class::VERSION).to satisfy &Gem::Version.method(:correct?)
  end
end
