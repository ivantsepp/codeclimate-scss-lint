require 'minitest/autorun'
require "minitest/reporters"
require "mocha/mini_test"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))
require "cc/engine/scss-lint"
