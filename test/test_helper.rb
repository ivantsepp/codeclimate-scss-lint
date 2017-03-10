require 'minitest/autorun'
require "minitest/reporters"
require "mocha/mini_test"
require "tempfile"
require "yaml"

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))
require "cc/engine/scss-lint"

def with_config_file_contents(content)
  file = Tempfile.new('config')
  file.write(content)
  file.close
  yield(file.path)
  file.unlink
end

def fixtures_path
  File.join(File.dirname(__FILE__), 'fixtures')
end
