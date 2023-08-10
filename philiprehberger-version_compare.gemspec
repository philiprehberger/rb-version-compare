# frozen_string_literal: true

require_relative 'lib/philiprehberger/version_compare/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-version_compare'
  spec.version = Philiprehberger::VersionCompare::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Version string parsing with comparison, sorting, and constraint matching'
  spec.description = 'Parse semantic version strings into comparable objects with support for ' \
                       'sorting, finding the latest version, and checking constraint satisfaction.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-version_compare'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-version-compare'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-version-compare/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-version-compare/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
