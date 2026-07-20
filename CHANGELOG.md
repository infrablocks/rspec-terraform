# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com)
and this project adheres to
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed

* The `output` helper now uses the return value of
  `RubyTerraform::Commands::Output#execute` instead of reading from a
  `StringIO` passed on construction. Since ruby-terraform 1.8.0, the
  command captures stdout internally and ignores a constructor-supplied
  stream, so the helper always saw an empty string and raised
  `JSON::ParserError`.
