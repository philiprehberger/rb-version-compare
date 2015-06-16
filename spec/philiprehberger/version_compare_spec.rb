# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::VersionCompare do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.parse' do
    it 'parses a full version string' do
      v = described_class.parse('1.2.3')
      expect(v.major).to eq(1)
      expect(v.minor).to eq(2)
      expect(v.patch).to eq(3)
    end

    it 'parses a version with pre-release' do
      v = described_class.parse('1.0.0-beta.1')
      expect(v.pre_release).to eq('beta.1')
    end

    it 'strips v prefix' do
      v = described_class.parse('v2.0.0')
      expect(v.major).to eq(2)
    end

    it 'defaults minor and patch to zero' do
      v = described_class.parse('3')
      expect(v.minor).to eq(0)
      expect(v.patch).to eq(0)
    end

    it 'raises for invalid input' do
      expect { described_class.parse('not.a.version.string') }.to raise_error(described_class::Error)
    end
  end

  describe 'SemanticVersion comparison' do
    it 'compares by major version' do
      expect(described_class.parse('2.0.0')).to be > described_class.parse('1.0.0')
    end

    it 'compares by minor version' do
      expect(described_class.parse('1.2.0')).to be > described_class.parse('1.1.0')
    end

    it 'compares by patch version' do
      expect(described_class.parse('1.0.2')).to be > described_class.parse('1.0.1')
    end

    it 'treats release as greater than pre-release' do
      expect(described_class.parse('1.0.0')).to be > described_class.parse('1.0.0-alpha')
    end

    it 'compares pre-release strings alphabetically' do
      expect(described_class.parse('1.0.0-beta')).to be > described_class.parse('1.0.0-alpha')
    end

    it 'considers equal versions equal' do
      expect(described_class.parse('1.0.0')).to eq(described_class.parse('1.0.0'))
    end
  end

  describe '#satisfies?' do
    let(:version) { described_class.parse('1.5.3') }

    it 'satisfies >= constraint' do
      expect(version.satisfies?('>= 1.0.0')).to be true
    end

    it 'does not satisfy >= constraint when less' do
      expect(version.satisfies?('>= 2.0.0')).to be false
    end

    it 'satisfies < constraint' do
      expect(version.satisfies?('< 2.0.0')).to be true
    end

    it 'satisfies != constraint' do
      expect(version.satisfies?('!= 1.0.0')).to be true
    end

    it 'does not satisfy != when equal' do
      expect(version.satisfies?('!= 1.5.3')).to be false
    end

    it 'satisfies ~> constraint (pessimistic)' do
      expect(version.satisfies?('~> 1.5')).to be true
    end

    it 'does not satisfy ~> when major differs' do
      expect(version.satisfies?('~> 2.0')).to be false
    end
  end

  describe '#to_s' do
    it 'returns version string' do
      expect(described_class.parse('1.2.3').to_s).to eq('1.2.3')
    end

    it 'includes pre-release' do
      expect(described_class.parse('1.0.0-rc.1').to_s).to eq('1.0.0-rc.1')
    end
  end

  describe '.sort' do
    it 'sorts version strings in ascending order' do
      versions = ['2.0.0', '1.0.0', '1.5.0', '0.1.0']
      expect(described_class.sort(versions)).to eq(['0.1.0', '1.0.0', '1.5.0', '2.0.0'])
    end
  end

  describe '.latest' do
    it 'returns the highest version' do
      versions = ['1.0.0', '2.0.0', '1.5.0']
      expect(described_class.latest(versions)).to eq('2.0.0')
    end

    it 'raises for empty array' do
      expect { described_class.latest([]) }.to raise_error(described_class::Error)
    end

    it 'returns the only version for a single-element array' do
      expect(described_class.latest(['1.0.0'])).to eq('1.0.0')
    end

    it 'considers pre-release lower than release' do
      versions = ['1.0.0-alpha', '1.0.0']
      expect(described_class.latest(versions)).to eq('1.0.0')
    end
  end

  describe '.parse' do
    it 'parses major.minor without patch' do
      v = described_class.parse('2.1')
      expect(v.major).to eq(2)
      expect(v.minor).to eq(1)
      expect(v.patch).to eq(0)
    end

    it 'raises for empty string' do
      expect { described_class.parse('') }.to raise_error(described_class::Error)
    end

    it 'raises for non-numeric string' do
      expect { described_class.parse('abc') }.to raise_error(described_class::Error)
    end

    it 'strips leading v prefix case-sensitively' do
      v = described_class.parse('v1.2.3')
      expect(v.to_s).to eq('1.2.3')
    end

    it 'handles whitespace around version string' do
      v = described_class.parse('  1.2.3  ')
      expect(v.major).to eq(1)
    end
  end

  describe 'SemanticVersion comparison' do
    it 'returns nil when comparing with non-SemanticVersion' do
      v = described_class.parse('1.0.0')
      expect(v <=> 'not a version').to be_nil
    end

    it 'considers two pre-release versions equal when same' do
      a = described_class.parse('1.0.0-alpha')
      b = described_class.parse('1.0.0-alpha')
      expect(a).to eq(b)
    end

    it 'orders rc after beta' do
      expect(described_class.parse('1.0.0-rc.1')).to be > described_class.parse('1.0.0-beta.1')
    end
  end

  describe '#satisfies?' do
    it 'satisfies = constraint for exact match' do
      v = described_class.parse('1.5.3')
      expect(v.satisfies?('= 1.5.3')).to be true
    end

    it 'does not satisfy = constraint for non-match' do
      v = described_class.parse('1.5.3')
      expect(v.satisfies?('= 1.5.4')).to be false
    end

    it 'satisfies <= constraint when equal' do
      v = described_class.parse('2.0.0')
      expect(v.satisfies?('<= 2.0.0')).to be true
    end

    it 'satisfies > constraint' do
      v = described_class.parse('2.0.0')
      expect(v.satisfies?('> 1.0.0')).to be true
    end

    it 'does not satisfy > constraint when equal' do
      v = described_class.parse('1.0.0')
      expect(v.satisfies?('> 1.0.0')).to be false
    end

    it 'satisfies bare version as = constraint' do
      v = described_class.parse('1.5.3')
      expect(v.satisfies?('1.5.3')).to be true
    end
  end

  describe '#to_s' do
    it 'does not include pre-release when nil' do
      v = described_class.parse('2.0.0')
      expect(v.to_s).to eq('2.0.0')
      expect(v.to_s).not_to include('-')
    end
  end

  describe '#inspect' do
    it 'returns a formatted string' do
      v = described_class.parse('1.2.3')
      expect(v.inspect).to eq('#<Version 1.2.3>')
    end
  end

  describe '.sort' do
    it 'sorts versions with pre-releases' do
      versions = ['1.0.0', '1.0.0-alpha', '1.0.0-beta']
      sorted = described_class.sort(versions)
      expect(sorted).to eq(['1.0.0-alpha', '1.0.0-beta', '1.0.0'])
    end

    it 'handles single version' do
      expect(described_class.sort(['1.0.0'])).to eq(['1.0.0'])
    end
  end
end
