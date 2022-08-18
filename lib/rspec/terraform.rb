# frozen_string_literal: true

require 'rspec/core'
require 'ruby_terraform'

require_relative 'terraform/version'
require_relative 'terraform/configuration'
require_relative 'terraform/matchers'
require_relative 'terraform/helpers'

RSpec.configure do |config|
  config.include(RSpec::Terraform::Matchers)
end
