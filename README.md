# RSpec::Terraform

An RSpec extension for verifying Terraform configurations, with support for:

* unit testing;
* integration testing;
* end-to-end testing; and
* change auditing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-terraform'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-terraform

## Usage

To use RSpec::Terraform, require it in your `spec_helper.rb` file:

```ruby
require 'rspec/terraform'
```

When required, RSpec::Terraform automatically configures itself against 
RSpec by:

* adding helper methods to interact with Terraform;
* adding matchers to verify Terraform plans; and
* adding settings to control RSpec::Terraform's behaviour.

The sections below provide further details on each of these additions.

### Helper methods

RSpec::Terraform adds helper methods to the RSpec DSL for planning, applying,
and destroying Terraform configurations, as well as accessing variables to and
outputs from Terraform configurations.

Each helper method takes a hash of parameters used to identify the configuration
against which to act and to provide as options to the Terraform command being
executed. Additionally, RSpec::Terraform includes a flexible approach to
resolving these parameters allowing them to be sourced from a variety of
locations. See the [Configuration Providers](#configuration-providers) section
for more details.

When executing helper methods, RSpec::Terraform provides two execution modes,
`:in_place` and `:isolated`. By default, RSpec::Terraform works against a
Terraform configuration _in place_, i.e., it executes commands against the
Terraform configuration directly, in the location specified. RSpec::Terraform
can also operate in an _isolated_ manner, wherein it initialises the
configuration into an isolated directory before executing commands. See the
[Execution Mode](#execution-mode) section for more details.

#### `plan`

The `plan` helper produces a Terraform plan for a configuration, reads it
into a Ruby representation and returns it.

`plan` requires a `:configuration_directory` parameter, representing the path
to the configuration to plan and is typically invoked in a `before(:context)`
hook, with the resulting plan stored for use in expectations:

```ruby
before(:context) do
  @plan = plan(
    configuration_directory: 'path/to/configuration/directory'
  )
end
```

If the configuration has input variables, a `:vars` parameter can be provided
as a hash:

```ruby
before(:context) do
  @plan = plan(
    configuration_directory: 'path/to/configuration/directory',
    vars: {
      region: 'uk',
      zones: ['uk-a', 'uk-b'],
      tags: {
        name: 'important-thing',
        role: 'persistence'
      }
    }
  )
end
```

or within a block:

```ruby
before(:context) do
  @plan = plan(
    configuration_directory: 'path/to/configuration/directory'
  ) do |vars|
    vars.region = 'uk'
    vars.zones = ['uk-a', 'uk-b']
    vars.tags = {
      name: 'important-thing',
      role: 'persistence'
    }
  end
end
```

`plan` accepts an optional `:state_file` parameter with the path to where the
current state file for the configuration is located, useful when checking the
incremental change that applying the configuration would have after a previous
apply.

Internally, `plan`:
* calls `terraform init` to initialise the configuration directory;
* calls `terraform plan` to produce a plan file;
* calls `terraform show` to read the contents of the plan file into a Ruby
  representation; and
* deletes the plan file.

Any additional parameters passed to `plan` are passed on to the underlying
Terraform invocations.

#### `apply`

#### `destroy`

#### `output`

#### `var`

### Plan Matchers

### Settings

#### Binary Location

#### Logging and Standard Streams

#### Execution Mode

The benefit of isolated execution is that nothing is carried over between test
runs and providers and modules are fetched into a clean configuration directory
every time. The downside is additional test run time.

#### Configuration Providers

### Frequently Asked Questions

## Development

To install dependencies and run the build, run the pre-commit build:

```shell
./go
```

This runs all unit tests and other checks including coverage and code linting /
formatting.

To run only the unit tests, including coverage:

```shell
./go test:unit
```

To attempt to fix any code linting / formatting issues:

```shell
./go library:fix
```

To check for code linting / formatting issues without fixing:

```shell
./go library:check
```

You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/infrablocks/rspec-terraform. This project is intended to be a 
safe, welcoming space for collaboration, and contributors are expected to 
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of 
conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
