# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  # minimum_coverage line: 90, branch: 90
  add_filter '/spec/'
end

require 'bundler/setup'

require 'rake'
require 'rspec/terraform'

Dir[File.join(__dir__, 'support', '**', '*.rb')]
  .each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
