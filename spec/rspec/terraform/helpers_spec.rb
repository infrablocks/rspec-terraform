# frozen_string_literal: true

require 'spec_helper'
require 'logger'

describe RSpec::Terraform::Helpers do
  let(:including_class) { Class.new { include RSpec::Terraform::Helpers } }

  describe '#apply' do
    def overridden_binary
      'path/to/binary'
    end

    def overridden_execution_mode
      :isolated
    end

    def overridden_configuration_provider
      @overridden_configuration_provider ||=
        RSpec::Terraform::Configuration
          .in_memory_provider(first: 1, second: 2)
    end

    def overridden_logger
      @overridden_logger ||= instance_double(Logger)
    end

    def overridden_stdin
      @overridden_stdin ||= StringIO.new
    end

    def overridden_stdout
      @overridden_stdout ||= StringIO.new
    end

    def overridden_stderr
      @overridden_stderr ||= StringIO.new
    end

    around do |example|
      config = RSpec.configuration

      previous_binary = config.terraform_binary
      previous_logger = config.terraform_logger
      previous_stdin = config.terraform_stdin
      previous_stdout = config.terraform_stdout
      previous_stderr = config.terraform_stderr
      previous_execution_mode = config.terraform_execution_mode
      previous_configuration_provider = config.terraform_configuration_provider

      config.terraform_binary = overridden_binary
      config.terraform_logger = overridden_logger
      config.terraform_stdin = overridden_stdin
      config.terraform_stdout = overridden_stdout
      config.terraform_stderr = overridden_stderr
      config.terraform_execution_mode = overridden_execution_mode
      config.terraform_configuration_provider =
        overridden_configuration_provider

      example.run

      config.terraform_binary = previous_binary
      config.terraform_logger = previous_logger
      config.terraform_stdin = previous_stdin
      config.terraform_stdout = previous_stdout
      config.terraform_stderr = previous_stderr
      config.terraform_execution_mode = previous_execution_mode
      config.terraform_configuration_provider = previous_configuration_provider
    end

    it 'constructs and executes the apply helper' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new).and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform binary on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(binary: overridden_binary))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform logger on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(logger: overridden_logger))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform stdin on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(stdin: overridden_stdin))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform stdout on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(stdout: overridden_stdout))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform stderr on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(stderr: overridden_stderr))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform execution mode on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(execution_mode: overridden_execution_mode))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    it 'passes the configured terraform configuration provider ' \
       'on construction' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new)
              .with(hash_including(
                      configuration_provider: overridden_configuration_provider
                    ))
              .and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'passes the supplied overrides and block on execution' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      overrides = {
        first: 'one',
        second: 'two'
      }
      block = lambda do |vars|
        vars.first = 'ONE'
      end

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new).and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply(overrides, &block)

      expect(apply).to(have_received(:execute) do |passed_opts, &passed_block|
        expect(passed_opts).to(eq(overrides))
        expect(passed_block).to(eq(block))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'defaults overrides to an empty map' do
      apply = instance_double(RSpec::Terraform::Helpers::Apply)

      allow(RSpec::Terraform::Helpers::Apply)
        .to(receive(:new).and_return(apply))
      allow(apply).to(receive(:execute))

      instance = including_class.new
      instance.apply

      expect(apply).to(have_received(:execute) do |passed_opts|
        expect(passed_opts).to(eq({}))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#destroy' do
    def overridden_binary
      'path/to/binary'
    end

    def overridden_execution_mode
      :isolated
    end

    def overridden_configuration_provider
      @overridden_configuration_provider ||=
        RSpec::Terraform::Configuration
          .in_memory_provider(first: 1, second: 2)
    end

    def overridden_logger
      @overridden_logger ||= instance_double(Logger)
    end

    def overridden_stdin
      @overridden_stdin ||= StringIO.new
    end

    def overridden_stdout
      @overridden_stdout ||= StringIO.new
    end

    def overridden_stderr
      @overridden_stderr ||= StringIO.new
    end

    around do |example|
      config = RSpec.configuration

      previous_binary = config.terraform_binary
      previous_logger = config.terraform_logger
      previous_stdin = config.terraform_stdin
      previous_stdout = config.terraform_stdout
      previous_stderr = config.terraform_stderr
      previous_execution_mode = config.terraform_execution_mode
      previous_configuration_provider = config.terraform_configuration_provider

      config.terraform_binary = overridden_binary
      config.terraform_logger = overridden_logger
      config.terraform_stdin = overridden_stdin
      config.terraform_stdout = overridden_stdout
      config.terraform_stderr = overridden_stderr
      config.terraform_execution_mode = overridden_execution_mode
      config.terraform_configuration_provider =
        overridden_configuration_provider

      example.run

      config.terraform_binary = previous_binary
      config.terraform_logger = previous_logger
      config.terraform_stdin = previous_stdin
      config.terraform_stdout = previous_stdout
      config.terraform_stderr = previous_stderr
      config.terraform_execution_mode = previous_execution_mode
      config.terraform_configuration_provider = previous_configuration_provider
    end

    it 'constructs and executes the destroy helper' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new).and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform binary on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(binary: overridden_binary))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform logger on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(logger: overridden_logger))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform stdin on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(stdin: overridden_stdin))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform stdout on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(stdout: overridden_stdout))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform stderr on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(stderr: overridden_stderr))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform execution mode on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(execution_mode: overridden_execution_mode))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    it 'passes the configured terraform configuration provider ' \
       'on construction' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new)
              .with(hash_including(
                      configuration_provider: overridden_configuration_provider
                    ))
              .and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'passes the supplied overrides and block on execution' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      overrides = {
        first: 'one',
        second: 'two'
      }
      block = lambda do |vars|
        vars.first = 'ONE'
      end

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new).and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy(overrides, &block)

      expect(destroy).to(have_received(:execute) do |passed_opts, &passed_block|
        expect(passed_opts).to(eq(overrides))
        expect(passed_block).to(eq(block))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'defaults overrides to an empty map' do
      destroy = instance_double(RSpec::Terraform::Helpers::Destroy)

      allow(RSpec::Terraform::Helpers::Destroy)
        .to(receive(:new).and_return(destroy))
      allow(destroy).to(receive(:execute))

      instance = including_class.new
      instance.destroy

      expect(destroy).to(have_received(:execute) do |passed_opts|
        expect(passed_opts).to(eq({}))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#output' do
    def overridden_binary
      'path/to/binary'
    end

    def overridden_execution_mode
      :isolated
    end

    def overridden_configuration_provider
      @overridden_configuration_provider ||=
        RSpec::Terraform::Configuration
          .in_memory_provider(first: 1, second: 2)
    end

    def overridden_logger
      @overridden_logger ||= instance_double(Logger)
    end

    def overridden_stdin
      @overridden_stdin ||= StringIO.new
    end

    def overridden_stdout
      @overridden_stdout ||= StringIO.new
    end

    def overridden_stderr
      @overridden_stderr ||= StringIO.new
    end

    around do |example|
      config = RSpec.configuration

      previous_binary = config.terraform_binary
      previous_logger = config.terraform_logger
      previous_stdin = config.terraform_stdin
      previous_stdout = config.terraform_stdout
      previous_stderr = config.terraform_stderr
      previous_execution_mode = config.terraform_execution_mode
      previous_configuration_provider = config.terraform_configuration_provider

      config.terraform_binary = overridden_binary
      config.terraform_logger = overridden_logger
      config.terraform_stdin = overridden_stdin
      config.terraform_stdout = overridden_stdout
      config.terraform_stderr = overridden_stderr
      config.terraform_execution_mode = overridden_execution_mode
      config.terraform_configuration_provider =
        overridden_configuration_provider

      example.run

      config.terraform_binary = previous_binary
      config.terraform_logger = previous_logger
      config.terraform_stdin = previous_stdin
      config.terraform_stdout = previous_stdout
      config.terraform_stderr = previous_stderr
      config.terraform_execution_mode = previous_execution_mode
      config.terraform_configuration_provider = previous_configuration_provider
    end

    it 'constructs and executes the output helper' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new).and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform binary on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(binary: overridden_binary))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform logger on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(logger: overridden_logger))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform stdin on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(stdin: overridden_stdin))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform stdout on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(stdout: overridden_stdout))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform stderr on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(stderr: overridden_stderr))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform execution mode on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(execution_mode: overridden_execution_mode))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    it 'passes the configured terraform configuration provider ' \
       'on construction' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new)
              .with(hash_including(
                      configuration_provider: overridden_configuration_provider
                    ))
              .and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'passes the supplied overrides and block on execution' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      overrides = {
        first: 'one',
        second: 'two'
      }
      block = lambda do |vars|
        vars.first = 'ONE'
      end

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new).and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output(overrides, &block)

      expect(output).to(have_received(:execute) do |passed_opts, &passed_block|
        expect(passed_opts).to(eq(overrides))
        expect(passed_block).to(eq(block))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'defaults overrides to an empty map' do
      output = instance_double(RSpec::Terraform::Helpers::Output)

      allow(RSpec::Terraform::Helpers::Output)
        .to(receive(:new).and_return(output))
      allow(output).to(receive(:execute))

      instance = including_class.new
      instance.output

      expect(output).to(have_received(:execute) do |passed_opts|
        expect(passed_opts).to(eq({}))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#plan' do
    def overridden_binary
      'path/to/binary'
    end

    def overridden_execution_mode
      :isolated
    end

    def overridden_configuration_provider
      @overridden_configuration_provider ||=
        RSpec::Terraform::Configuration
          .in_memory_provider(first: 1, second: 2)
    end

    def overridden_logger
      @overridden_logger ||= instance_double(Logger)
    end

    def overridden_stdin
      @overridden_stdin ||= StringIO.new
    end

    def overridden_stdout
      @overridden_stdout ||= StringIO.new
    end

    def overridden_stderr
      @overridden_stderr ||= StringIO.new
    end

    around do |example|
      config = RSpec.configuration

      previous_binary = config.terraform_binary
      previous_logger = config.terraform_logger
      previous_stdin = config.terraform_stdin
      previous_stdout = config.terraform_stdout
      previous_stderr = config.terraform_stderr
      previous_execution_mode = config.terraform_execution_mode
      previous_configuration_provider = config.terraform_configuration_provider

      config.terraform_binary = overridden_binary
      config.terraform_logger = overridden_logger
      config.terraform_stdin = overridden_stdin
      config.terraform_stdout = overridden_stdout
      config.terraform_stderr = overridden_stderr
      config.terraform_execution_mode = overridden_execution_mode
      config.terraform_configuration_provider =
        overridden_configuration_provider

      example.run

      config.terraform_binary = previous_binary
      config.terraform_logger = previous_logger
      config.terraform_stdin = previous_stdin
      config.terraform_stdout = previous_stdout
      config.terraform_stderr = previous_stderr
      config.terraform_execution_mode = previous_execution_mode
      config.terraform_configuration_provider = previous_configuration_provider
    end

    it 'constructs and executes the plan helper' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new).and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform binary on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(binary: overridden_binary))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform logger on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(logger: overridden_logger))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform stdin on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(stdin: overridden_stdin))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform stdout on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(stdout: overridden_stdout))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform stderr on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(stderr: overridden_stderr))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform execution mode on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(execution_mode: overridden_execution_mode))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    it 'passes the configured terraform configuration provider ' \
       'on construction' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new)
              .with(hash_including(
                      configuration_provider: overridden_configuration_provider
                    ))
              .and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'passes the supplied overrides and block on execution' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      overrides = {
        first: 'one',
        second: 'two'
      }
      block = lambda do |vars|
        vars.first = 'ONE'
      end

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new).and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan(overrides, &block)

      expect(plan).to(have_received(:execute) do |passed_opts, &passed_block|
        expect(passed_opts).to(eq(overrides))
        expect(passed_block).to(eq(block))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'defaults overrides to an empty map' do
      plan = instance_double(RSpec::Terraform::Helpers::Plan)

      allow(RSpec::Terraform::Helpers::Plan)
        .to(receive(:new).and_return(plan))
      allow(plan).to(receive(:execute))

      instance = including_class.new
      instance.plan

      expect(plan).to(have_received(:execute) do |passed_opts|
        expect(passed_opts).to(eq({}))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe '#var' do
    def overridden_configuration_provider
      @overridden_configuration_provider ||=
        RSpec::Terraform::Configuration
          .in_memory_provider(first: 1, second: 2)
    end

    def overridden_logger
      @overridden_logger ||= instance_double(Logger)
    end

    around do |example|
      config = RSpec.configuration

      previous_logger = config.terraform_logger
      previous_configuration_provider = config.terraform_configuration_provider

      config.terraform_logger = overridden_logger
      config.terraform_configuration_provider =
        overridden_configuration_provider

      example.run

      config.terraform_logger = previous_logger
      config.terraform_configuration_provider = previous_configuration_provider
    end

    it 'constructs and executes the var helper' do
      var = instance_double(RSpec::Terraform::Helpers::Var)

      allow(RSpec::Terraform::Helpers::Var)
        .to(receive(:new).and_return(var))
      allow(var).to(receive(:execute))

      instance = including_class.new
      instance.var

      expect(var).to(have_received(:execute))
    end

    it 'passes the configured terraform logger on construction' do
      var = instance_double(RSpec::Terraform::Helpers::Var)

      allow(RSpec::Terraform::Helpers::Var)
        .to(receive(:new)
              .with(hash_including(logger: overridden_logger))
              .and_return(var))
      allow(var).to(receive(:execute))

      instance = including_class.new
      instance.var

      expect(var).to(have_received(:execute))
    end

    it 'passes the configured terraform configuration provider ' \
       'on construction' do
      var = instance_double(RSpec::Terraform::Helpers::Var)

      allow(RSpec::Terraform::Helpers::Var)
        .to(receive(:new)
              .with(hash_including(
                      configuration_provider: overridden_configuration_provider
                    ))
              .and_return(var))
      allow(var).to(receive(:execute))

      instance = including_class.new
      instance.var

      expect(var).to(have_received(:execute))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'passes the supplied overrides and block on execution' do
      var = instance_double(RSpec::Terraform::Helpers::Var)

      overrides = {
        first: 'one',
        second: 'two'
      }
      block = lambda do |vars|
        vars.first = 'ONE'
      end

      allow(RSpec::Terraform::Helpers::Var)
        .to(receive(:new).and_return(var))
      allow(var).to(receive(:execute))

      instance = including_class.new
      instance.var(overrides, &block)

      expect(var).to(have_received(:execute) do |passed_opts, &passed_block|
        expect(passed_opts).to(eq(overrides))
        expect(passed_block).to(eq(block))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'defaults overrides to an empty map' do
      var = instance_double(RSpec::Terraform::Helpers::Var)

      allow(RSpec::Terraform::Helpers::Var)
        .to(receive(:new).and_return(var))
      allow(var).to(receive(:execute))

      instance = including_class.new
      instance.var

      expect(var).to(have_received(:execute) do |passed_opts|
        expect(passed_opts).to(eq({}))
      end)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
