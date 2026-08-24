# frozen_string_literal: true

# Provide one entry point for CI and local development that discovers every
# Ruby test as the suite grows.
require_relative "test_helper"

Dir[File.join(__dir__, "**", "*_test.rb")].sort.each { |file| require file }
