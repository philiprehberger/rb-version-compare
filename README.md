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

### Sorting and Latest

```ruby
versions = ['2.0.0', '1.0.0', '1.5.0', '0.1.0']

Philiprehberger::VersionCompare.sort(versions)
# => ["0.1.0", "1.0.0", "1.5.0", "2.0.0"]

Philiprehberger::VersionCompare.latest(versions)
# => "2.0.0"
```

## API

### `Philiprehberger::VersionCompare`

| Method | Description |
|--------|-------------|
| `.parse(str)` | Parse a version string into a `SemanticVersion` |
| `.sort(versions)` | Sort an array of version strings in ascending order |
| `.latest(versions)` | Return the highest version string from an array |

### `SemanticVersion`

| Method | Description |
|--------|-------------|
| `#major` | Major version number |
| `#minor` | Minor version number |
| `#patch` | Patch version number |
| `#pre_release` | Pre-release identifier or nil |
| `#satisfies?(constraint)` | Check if version satisfies a constraint (`>=`, `<`, `~>`, `!=`) |
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
