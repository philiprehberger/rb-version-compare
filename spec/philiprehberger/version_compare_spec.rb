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

    it 'parses version with build metadata' do
      v = described_class.parse('1.2.3+build.123')
      expect(v.major).to eq(1)
      expect(v.minor).to eq(2)
      expect(v.patch).to eq(3)
      expect(v.build_metadata).to eq('build.123')
    end

    it 'parses version with pre-release and build metadata' do
      v = described_class.parse('1.0.0-beta.1+exp.sha.5114f85')
      expect(v.pre_release).to eq('beta.1')
      expect(v.build_metadata).to eq('exp.sha.5114f85')
    end

    it 'returns nil build_metadata when none is present' do
      v = described_class.parse('1.0.0')
      expect(v.build_metadata).to be_nil
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

    it 'ignores build metadata in comparison' do
      a = described_class.parse('1.0.0+build.1')
      b = described_class.parse('1.0.0+build.2')
      expect(a).to eq(b)
    end

    it 'ignores build metadata when comparing with pre-release' do
      a = described_class.parse('1.0.0-alpha+build.1')
      b = described_class.parse('1.0.0-alpha+build.2')
      expect(a).to eq(b)
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

    it 'satisfies = constraint for exact match' do
      expect(version.satisfies?('= 1.5.3')).to be true
    end

    it 'does not satisfy = constraint for non-match' do
      expect(version.satisfies?('= 1.5.4')).to be false
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
      expect(version.satisfies?('1.5.3')).to be true
    end
  end

  describe '#next_major' do
    it 'increments major and resets minor and patch' do
      v = described_class.parse('1.2.3').next_major
      expect(v.to_s).to eq('2.0.0')
    end

    it 'drops pre-release' do
      v = described_class.parse('1.0.0-beta.1').next_major
      expect(v.pre_release).to be_nil
      expect(v.to_s).to eq('2.0.0')
    end

    it 'drops build metadata' do
      v = described_class.parse('1.0.0+build.1').next_major
      expect(v.build_metadata).to be_nil
    end
  end

  describe '#next_minor' do
    it 'increments minor and resets patch' do
      v = described_class.parse('1.2.3').next_minor
      expect(v.to_s).to eq('1.3.0')
    end

    it 'drops pre-release' do
      v = described_class.parse('1.2.0-rc.1').next_minor
      expect(v.pre_release).to be_nil
      expect(v.to_s).to eq('1.3.0')
    end
  end

  describe '#next_patch' do
    it 'increments patch' do
      v = described_class.parse('1.2.3').next_patch
      expect(v.to_s).to eq('1.2.4')
    end

    it 'drops pre-release' do
      v = described_class.parse('1.2.3-alpha').next_patch
      expect(v.pre_release).to be_nil
      expect(v.to_s).to eq('1.2.4')
    end
  end

  describe '#stable?' do
    it 'returns true for stable versions' do
      expect(described_class.parse('1.0.0').stable?).to be true
    end

    it 'returns false for pre-release versions' do
      expect(described_class.parse('1.0.0-beta').stable?).to be false
    end

    it 'returns true for version with only build metadata' do
      expect(described_class.parse('1.0.0+build.1').stable?).to be true
    end
  end

  describe '#to_a' do
    it 'returns [major, minor, patch]' do
      expect(described_class.parse('1.2.3').to_a).to eq([1, 2, 3])
    end

    it 'does not include pre-release or build metadata' do
      expect(described_class.parse('1.2.3-beta+build').to_a).to eq([1, 2, 3])
    end
  end

  describe '#to_s' do
    it 'returns version string' do
      expect(described_class.parse('1.2.3').to_s).to eq('1.2.3')
    end

    it 'includes pre-release' do
      expect(described_class.parse('1.0.0-rc.1').to_s).to eq('1.0.0-rc.1')
    end

    it 'does not include pre-release when nil' do
      v = described_class.parse('2.0.0')
      expect(v.to_s).to eq('2.0.0')
      expect(v.to_s).not_to include('-')
    end

    it 'includes build metadata' do
      expect(described_class.parse('1.0.0+build.123').to_s).to eq('1.0.0+build.123')
    end

    it 'includes both pre-release and build metadata' do
      expect(described_class.parse('1.0.0-beta+build.123').to_s).to eq('1.0.0-beta+build.123')
    end
  end

  describe '#inspect' do
    it 'returns a formatted string' do
      v = described_class.parse('1.2.3')
      expect(v.inspect).to eq('#<Version 1.2.3>')
    end
  end

  describe '.sort' do
    it 'sorts version strings in ascending order' do
      versions = ['2.0.0', '1.0.0', '1.5.0', '0.1.0']
      expect(described_class.sort(versions)).to eq(['0.1.0', '1.0.0', '1.5.0', '2.0.0'])
    end

    it 'sorts versions with pre-releases' do
      versions = ['1.0.0', '1.0.0-alpha', '1.0.0-beta']
      sorted = described_class.sort(versions)
      expect(sorted).to eq(['1.0.0-alpha', '1.0.0-beta', '1.0.0'])
    end

    it 'handles single version' do
      expect(described_class.sort(['1.0.0'])).to eq(['1.0.0'])
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

  describe '.filter' do
    let(:versions) { ['0.9.0', '1.0.0', '1.5.0', '2.0.0', '2.1.0-beta'] }

    it 'filters versions by >= constraint' do
      expect(described_class.filter(versions, '>= 1.0.0')).to eq(['1.0.0', '1.5.0', '2.0.0', '2.1.0-beta'])
    end

    it 'filters versions by < constraint' do
      expect(described_class.filter(versions, '< 2.0.0')).to eq(['0.9.0', '1.0.0', '1.5.0'])
    end

    it 'filters versions by ~> constraint' do
      expect(described_class.filter(versions, '~> 1.0')).to eq(['1.0.0', '1.5.0'])
    end

    it 'returns empty array when no versions match' do
      expect(described_class.filter(versions, '>= 3.0.0')).to eq([])
    end

    it 'returns all versions when all match' do
      expect(described_class.filter(versions, '>= 0.1.0')).to eq(versions)
    end
  end

  describe '.highest_satisfying' do
    it 'returns the single matching version when only one matches' do
      versions = ['0.9.0', '1.0.0', '2.0.0']
      expect(described_class.highest_satisfying(versions, '~> 1.0')).to eq('1.0.0')
    end

    it 'returns the highest version when multiple match' do
      versions = ['1.0.0', '1.5.0', '1.9.3', '2.0.0']
      expect(described_class.highest_satisfying(versions, '>= 1.0.0')).to eq('2.0.0')
    end

    it 'returns the highest matching version ignoring higher non-matching versions' do
      versions = ['1.0.0', '1.2.0', '1.5.0', '2.0.0', '3.0.0']
      expect(described_class.highest_satisfying(versions, '< 2.0.0')).to eq('1.5.0')
    end

    it 'returns nil when no version matches' do
      versions = ['0.9.0', '1.0.0', '1.5.0']
      expect(described_class.highest_satisfying(versions, '>= 2.0.0')).to be_nil
    end

    it 'returns nil when versions is empty' do
      expect(described_class.highest_satisfying([], '>= 1.0.0')).to be_nil
    end

    it 'prefers stable over pre-release when both satisfy the constraint' do
      versions = ['1.0.0-beta', '1.0.0', '1.0.0-rc.1']
      expect(described_class.highest_satisfying(versions, '>= 1.0.0-alpha')).to eq('1.0.0')
    end

    it 'returns a pre-release when it is the highest match' do
      versions = ['1.0.0-alpha', '1.0.0-beta', '1.0.0-rc.1']
      expect(described_class.highest_satisfying(versions, '< 1.0.0')).to eq('1.0.0-rc.1')
    end

    it 'preserves the original string form of the matched version' do
      versions = ['v1.0.0', 'v1.2.0', 'v1.5.0']
      expect(described_class.highest_satisfying(versions, '>= 1.0.0')).to eq('v1.5.0')
    end

    it 'works with unsorted input' do
      versions = ['2.0.0', '1.0.0', '1.5.0', '0.9.0']
      expect(described_class.highest_satisfying(versions, '~> 1.0')).to eq('1.5.0')
    end

    it 'returns the exact match for = constraint' do
      versions = ['1.0.0', '1.5.0', '2.0.0']
      expect(described_class.highest_satisfying(versions, '= 1.5.0')).to eq('1.5.0')
    end
  end
end
