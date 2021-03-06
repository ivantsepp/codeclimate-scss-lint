require "test_helper"

class TestSCSSLint < Minitest::Test
  def test_run_invokes_cli_with_options
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
      has_entries(
        reporters: [["Codeclimate", :stdout]],
        required_paths: [],
        files: ["./"]
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

  def test_skip_run_if_no_files_to_analyze
    ::SCSSLint::CLI.any_instance.expects(:act_on_options).never

    config_contents = <<-JSON
    {
      "include_paths": ["not-scss.rb"]
    }
    JSON

    with_config_file_contents(config_contents) do |path|
      CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: path).run
    end
  end

  def test_run_invokes_cli_with_config
    Tempfile.open('somefile.yml', File.dirname(__FILE__)) do |f|
      ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
        has_entries(
          reporters: [["Codeclimate", :stdout]],
          required_paths: [],
          files: ["./"],
          config_file: File.basename(f.path)
        )
      )

      with_config_file_contents('{"config":"' + File.basename(f.path) + '"}') do |path|
        CC::Engine::SCSSLint.new(directory: File.dirname(__FILE__), config_path: path).run
      end
    end
  end

  def test_run_invokes_cli_with_config_that_has_scss_files
    Tempfile.open('somefile.yml', fixtures_path) do |f|
      scss_config = {
        scss_files: 'app/stylesheets'
      }
      f.write(scss_config.to_yaml)

      ::SCSSLint::CLI.any_instance.expects(:act_on_options).with(
        has_entries(
          reporters: [["Codeclimate", :stdout]],
          required_paths: [],
          files: ["app/stylesheets/application.scss", "app/stylesheets/modules/colors.scss"],
          config_file: File.basename(f.path)
        )
      )

      config_contents = <<-JSON
      {
        "config": "#{File.basename(f.path)}",
        "include_paths": [
          "app/stylesheets/application.scss",
          "app/stylesheets/modules/"
        ]
      }
      JSON

      with_config_file_contents(config_contents) do |path|
        CC::Engine::SCSSLint.new(directory: fixtures_path, config_path: path).run
      end
    end
  end
end
