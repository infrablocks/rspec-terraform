# frozen_string_literal: true

require 'ruby_terraform'

module RSpec
  module Terraform
    module Configuration
      module Providers
        class Base
          def resolve(_ = {}); end
          def reset; end
        end
      end
    end
  end
end
