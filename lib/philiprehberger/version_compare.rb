# frozen_string_literal: true

require_relative 'version_compare/version'

module Philiprehberger
  module VersionCompare
    class Error < StandardError; end

    # A parsed semantic version with comparison support
    class SemanticVersion
      include Comparable

      attr_reader :major, :minor, :patch, :pre_release, :build_metadata

      # @param major [Integer] major version number
      # @param minor [Integer] minor version number
      # @param patch [Integer] patch version number
      # @param pre_release [String, nil] pre-release identifier
      # @param build_metadata [String, nil] build metadata (ignored in comparison)
      def initialize(major, minor, patch, pre_release: nil, build_metadata: nil)
        @major = major
        @minor = minor
        @patch = patch
        @pre_release = pre_release
        @build_metadata = build_metadata
      end

      # Compare two versions following SemVer precedence
      #
      # @param other [SemanticVersion] the other version
      # @return [Integer] -1, 0, or 1
      def <=>(other)
        return nil unless other.is_a?(SemanticVersion)

        result = [major, minor, patch] <=> [other.major, other.minor, other.patch]
        return result unless result.zero?

        compare_pre_release(other)
      end

      # Check if this version satisfies a constraint string
      #
      # @param constraint [String] constraint like ">= 1.0.0", "~> 2.1", "!= 1.2.3", "< 3.0.0"
      # @return [Boolean] true if the version satisfies the constraint
      # @raise [Error] if the constraint format is invalid
      def satisfies?(constraint)
        operator, version_str = parse_constraint(constraint)
        other = VersionCompare.parse(version_str)

        case operator
        when '>='
          self >= other
        when '<='
          self <= other
        when '>'
          self > other
        when '<'
          self < other
        when '='
          self == other
        when '!='
          self != other
        when '~>'
          pessimistic_match?(other)
        else
          raise Error, "unknown operator: #{operator}"
        end
      end

      # Return a new version with major incremented, minor and patch reset to 0
      #
      # @return [SemanticVersion] next major version
      def next_major
        SemanticVersion.new(major + 1, 0, 0)
      end

      # Return a new version with minor incremented, patch reset to 0
      #
      # @return [SemanticVersion] next minor version
      def next_minor
        SemanticVersion.new(major, minor + 1, 0)
      end

      # Return a new version with patch incremented
      #
      # @return [SemanticVersion] next patch version
      def next_patch
        SemanticVersion.new(major, minor, patch + 1)
      end

      # Check if the version is stable (no pre-release tag)
      #
      # @return [Boolean] true if no pre-release identifier
      def stable?
        pre_release.nil?
      end

      # Return the version components as an array
      #
      # @return [Array<Integer>] [major, minor, patch]
      def to_a
        [major, minor, patch]
      end

      # @return [String] version string representation
      def to_s
        base = "#{major}.#{minor}.#{patch}"
        base = "#{base}-#{pre_release}" if pre_release
        base = "#{base}+#{build_metadata}" if build_metadata
        base
      end

      def inspect
        "#<Version #{self}>"
      end

      private

      def compare_pre_release(other)
        return 0 if pre_release.nil? && other.pre_release.nil?
        return 1 if pre_release.nil?
        return -1 if other.pre_release.nil?

        pre_release <=> other.pre_release
      end

      def parse_constraint(constraint)
        match = constraint.strip.match(/\A(>=|<=|~>|!=|>|<|=)?\s*(.+)\z/)
        raise Error, "invalid constraint: #{constraint}" unless match

        operator = match[1] || '='
        [operator, match[2].strip]
      end

      def pessimistic_match?(other)
        return false if self < other

        if other.patch.zero? && other.minor.zero?
          major == other.major
        elsif other.patch.zero?
          major == other.major && minor == other.minor
        else
          major == other.major && minor == other.minor
        end
      end
    end

    # Parse a version string into a SemanticVersion
    #
    # @param str [String] version string like "1.2.3", "1.2.3-beta.1", or "1.2.3+build.123"
    # @return [SemanticVersion] parsed version
    # @raise [Error] if the string is not a valid version
    def self.parse(str)
      str = str.to_s.strip
      str = str.sub(/\Av/, '')

      match = str.match(/\A(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:-([a-zA-Z0-9.]+))?(?:\+([a-zA-Z0-9.]+))?\z/)
      raise Error, "invalid version: #{str}" unless match

      SemanticVersion.new(
        match[1].to_i,
        (match[2] || '0').to_i,
        (match[3] || '0').to_i,
        pre_release: match[4],
        build_metadata: match[5]
      )
    end

    # Sort an array of version strings
    #
    # @param versions [Array<String>] version strings to sort
    # @return [Array<String>] sorted version strings (ascending)
    def self.sort(versions)
      versions.sort_by { |v| parse(v) }
    end

    # Return the latest version from an array of version strings
    #
    # @param versions [Array<String>] version strings
    # @return [String] the latest version string
    # @raise [Error] if the array is empty
    def self.latest(versions)
      raise Error, 'no versions provided' if versions.empty?

      versions.max_by { |v| parse(v) }
    end

    # Filter an array of version strings by a constraint
    #
    # @param versions [Array<String>] version strings to filter
    # @param constraint [String] constraint like ">= 1.0.0", "~> 2.1"
    # @return [Array<String>] versions that satisfy the constraint
    def self.filter(versions, constraint)
      versions.select { |v| parse(v).satisfies?(constraint) }
    end
  end
end
