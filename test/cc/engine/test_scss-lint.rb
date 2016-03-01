require "test_helper"

class TestSCSSLint < Minitest::Test
  def test_run_invokes_cli_with_options
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: []
      )
    )

    CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: "{}").run
  end

  def test_run_invokes_cli_with_exclude
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: ["somefile.scss", "a_dir/"]
      )
    )

    config_contents = <<-JSON
    {
      "include_paths": [
        "somefile.scss",
        "a_dir/",
        "not-scss.rb"
      ]
    }
    JSON

    with_config_file_contents(config_contents) do |path|
      CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: path).run
    end
  end

  def test_run_invokes_cli_with_config
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: [],
        config_file: "somefile.scss"
      )
    )

    with_config_file_contents('{"config":"somefile.scss"}') do |path|
      CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: path).run
    end
  end
end
