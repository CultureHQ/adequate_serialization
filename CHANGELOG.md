# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2019-12-31

### Added

- The `oj` dependency.
- We now automatically bust caches using a background job on a many->one relationship.
- Add the ability to configure the ActiveJob queue that's used like so:

```ruby
AdequateSerialization.configure do |config|
  config.active_job_queue = :low
end
```

## [1.0.1] - 2019-12-31

### Changed

- Fix up Ruby 2.7 warnings.

## [1.0.0] - 2019-03-25

### Added

- The ability to define serializers inline in the object they're serializing.

### Changed

- Renamed the `AdequateSerialization::Steps::PassthroughStep` class to just `AdequateSerialization::Steps::Step`.

### Removed

- `AdequateSerialization.hook_into_rails!` is now no longer necessary as we assume you want to if `::Rails` is defined.

## [0.1.1] - 2018-08-30

### Changed

- No longer trigger another query when the `ActiveRecord` relation being serialized isn't loaded.

[unreleased]: https://github.com/CultureHQ/adequate_serialization/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/CultureHQ/adequate_serialization/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/CultureHQ/adequate_serialization/compare/v0.1.1...v1.0.0
[0.1.1]: https://github.com/CultureHQ/adequate_serialization/compare/fcc7c7...v0.1.1
