require 'scss_lint'
require 'scss_lint/cli'
require 'scss_lint/reporters/codeclimate_reporter'

module CC
  module Engine
    class SCSSLint

      def initialize(directory:, config_path:, io: STDOUT)
        self.directory = directory
        self.engine_config = JSON.parse config_path
        # self.engine_config = parse_config(config_path)
        self.cli = ::SCSSLint::CLI.new
      end

      def run
        options = scss_lint_options
        Dir.chdir(directory) do
          cli.send(:act_on_options, options)
        end
      end

      private

      attr_accessor :directory, :engine_config, :cli

      def scss_lint_options
        excluded_files = Array(engine_config["exclude_paths"])
        options = {
          reporters: [
            ["Codeclimate", :stdout]
          ],
          required_paths: [], # the codeclimate report is required above
          files: [], # execute SCSSLint::CLI in the `directory` path
          excluded_files: excluded_files
        }
        if engine_config["config"]
          options[:config_file] = engine_config["config"]
        end
        # if engine_config["config"] && File.exists?(engine_config["config"])
        #   options[:config_file] = File.join(directory, engine_config["config"])
        # end
        options
      end

      def parse_config(config_path)
        File.exists?(config_path) ? JSON.parse(File.read(config_path)) : {}
      end

    end
  end
end
