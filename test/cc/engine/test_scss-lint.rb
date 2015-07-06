require "test_helper"

class TestSCSSLint < Minitest::Test
  def test_run_invokes_cli_with_options
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: [],
        excluded_files: []
      )
    )

    CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: "{}").run
  end

  def test_run_invokes_cli_with_exclude
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: [],
        excluded_files: ['somefile.scss']
      )
    )

    CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: '{"exclude_paths":["somefile.scss"]}').run
  end

  def test_run_invokes_cli_with_config
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: [],
        excluded_files: [],
        config_file: "somefile.scss"
      )
    )

    CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: '{"config":"somefile.scss"}').run
  end
end
