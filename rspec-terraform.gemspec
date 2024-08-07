# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/terraform/version'

files = %w[
  bin
  lib
  CODE_OF_CONDUCT.md
  rspec-terraform.gemspec
  Gemfile
  LICENSE.txt
  Rakefile
  README.md
]

Gem::Specification.new do |spec|
  spec.name = 'rspec-terraform'
  spec.version = RSpec::Terraform::VERSION
  spec.authors = ['InfraBlocks Maintainers']
  spec.email = ['maintainers@infrablocks.io']

  spec.summary = 'RSpec support for testing Terraform configurations.'
  spec.description =
    'Helpers, contexts and matchers to support using RSpec to test Terraform ' \
    'configurations and modules.'
  spec.homepage = 'https://github.com/infrablocks/rspec-terraform'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(/^(#{files.map { |g| Regexp.escape(g) }.join('|')})/)
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1'

  spec.add_dependency 'confidante', '>= 0.27'
  spec.add_dependency 'rspec', '>= 3.0'
  spec.add_dependency 'ruby-terraform', '1.8.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'gem-release'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rake_circle_ci'
  spec.add_development_dependency 'rake_git'
  spec.add_development_dependency 'rake_git_crypt'
  spec.add_development_dependency 'rake_github'
  spec.add_development_dependency 'rake_gpg'
  spec.add_development_dependency 'rake_ssh'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'terminal-notifier-guard'

  spec.metadata['rubygems_mfa_required'] = 'false'
end
