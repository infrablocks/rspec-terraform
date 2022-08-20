# frozen_string_literal: true

require 'rspec/core'
require 'ruby_terraform'

require_relative 'terraform/version'
require_relative 'terraform/configuration'
require_relative 'terraform/matchers'
require_relative 'terraform/helpers'

RSpec.configure do |config|
  config.include(RSpec::Terraform::Matchers)

  config.add_setting(:terraform_binary, default: 'terraform')
  config.add_setting(:terraform_execution_mode, default: :in_place)
end
