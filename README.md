# philiprehberger-version_compare

[![Tests](https://github.com/philiprehberger/rb-version-compare/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-version-compare/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-version_compare.svg)](https://rubygems.org/gems/philiprehberger-version_compare)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-version-compare)](https://github.com/philiprehberger/rb-version-compare/commits/main)

Version string parsing with comparison, sorting, and constraint matching

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-version_compare"
```

Or install directly:

```bash
gem install philiprehberger-version_compare
```

## Usage

```ruby
require "philiprehberger/version_compare"

v = Philiprehberger::VersionCompare.parse('1.2.3')
v.major       # => 1
v.minor       # => 2
v.patch       # => 3
v.pre_release # => nil
```

### Comparison

```ruby
v1 = Philiprehberger::VersionCompare.parse('1.0.0')
v2 = Philiprehberger::VersionCompare.parse('2.0.0')

v1 < v2  # => true
v1 == v2 # => false
```

### Pre-release Versions

```ruby
v = Philiprehberger::VersionCompare.parse('1.0.0-beta.1')
v.pre_release # => "beta.1"

# Release versions are greater than pre-release
Philiprehberger::VersionCompare.parse('1.0.0') > Philiprehberger::VersionCompare.parse('1.0.0-alpha')
# => true
```

### Constraint Matching

```ruby
v = Philiprehberger::VersionCompare.parse('1.5.3')

v.satisfies?('>= 1.0.0') # => true
v.satisfies?('< 2.0.0')  # => true
v.satisfies?('~> 1.5')   # => true
v.satisfies?('!= 1.0.0') # => true
```

### Version Bumping

```ruby
v = Philiprehberger::VersionCompare.parse('1.2.3')

v.next_major.to_s # => "2.0.0"
v.next_minor.to_s # => "1.3.0"
v.next_patch.to_s # => "1.2.4"
```

### Build Metadata

```ruby
v = Philiprehberger::VersionCompare.parse('1.0.0+build.123')
v.build_metadata # => "build.123"

# Build metadata is ignored in comparison (per SemVer spec)
a = Philiprehberger::VersionCompare.parse('1.0.0+build.1')
b = Philiprehberger::VersionCompare.parse('1.0.0+build.2')
a == b # => true
```

### Stability Check

```ruby
Philiprehberger::VersionCompare.parse('1.0.0').stable?       # => true
Philiprehberger::VersionCompare.parse('1.0.0-beta').stable?   # => false
```

### Sorting and Latest

```ruby
versions = ['2.0.0', '1.0.0', '1.5.0', '0.1.0']

Philiprehberger::VersionCompare.sort(versions)
# => ["0.1.0", "1.0.0", "1.5.0", "2.0.0"]

Philiprehberger::VersionCompare.latest(versions)
# => "2.0.0"
```

### Filtering

```ruby
versions = ['0.9.0', '1.0.0', '1.5.0', '2.0.0']

Philiprehberger::VersionCompare.filter(versions, '>= 1.0.0')
# => ["1.0.0", "1.5.0", "2.0.0"]

Philiprehberger::VersionCompare.filter(versions, '~> 1.0')
# => ["1.0.0", "1.5.0"]
```

### Highest satisfying version

```ruby
versions = ['0.9.0', '1.0.0', '1.5.0', '2.0.0', '3.0.0']

Philiprehberger::VersionCompare.highest_satisfying(versions, '~> 1.0')
# => "1.5.0"

Philiprehberger::VersionCompare.highest_satisfying(versions, '< 2.0.0')
# => "1.5.0"

# Returns nil when no version matches
Philiprehberger::VersionCompare.highest_satisfying(versions, '>= 4.0.0')
# => nil
```

## API

### `Philiprehberger::VersionCompare`

| Method | Description |
|--------|-------------|
| `.parse(str)` | Parse a version string into a `SemanticVersion` |
| `.sort(versions)` | Sort an array of version strings in ascending order |
| `.latest(versions)` | Return the highest version string from an array |
| `.filter(versions, constraint)` | Filter an array of version strings by a constraint |
| `.highest_satisfying(versions, constraint)` | Return the highest version string that satisfies a constraint, or `nil` |

### `SemanticVersion`

| Method | Description |
|--------|-------------|
| `#major` | Major version number |
| `#minor` | Minor version number |
| `#patch` | Patch version number |
| `#pre_release` | Pre-release identifier or nil |
| `#build_metadata` | Build metadata string or nil |
| `#satisfies?(constraint)` | Check if version satisfies a constraint (`>=`, `<`, `~>`, `!=`) |
| `#next_major` | New version with major+1, minor=0, patch=0 |
| `#next_minor` | New version with minor+1, patch=0 |
| `#next_patch` | New version with patch+1 |
| `#stable?` | True if no pre-release tag |
| `#to_a` | Returns `[major, minor, patch]` array |
| `#<=>(other)` | Compare two versions (includes `Comparable`) |
| `#to_s` | String representation of the version |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-version-compare)

🐛 [Report issues](https://github.com/philiprehberger/rb-version-compare/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-version-compare/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
