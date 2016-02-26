require 'scss_lint'
require 'scss_lint/cli'
require 'scss_lint/file_finder'
require 'scss_lint/reporters/codeclimate_reporter'

module CC
  module Engine
    class SCSSLint
      def initialize(directory:, config_path:, io: STDOUT)
        self.directory = directory
        self.engine_config = parse_config(config_path)
        self.cli = ::SCSSLint::CLI.new(::SCSSLint::Logger.new(STDERR))
      end

      def run
        options = scss_lint_options
        if options[:files] && options[:files].count > 0
          Dir.chdir(directory) do
            begin
              cli.send(:act_on_options, options)
            rescue ::SCSSLint::Exceptions::NoFilesError
            end
          end
        end
      end

      private

      attr_accessor :directory, :engine_config, :cli

      def scss_lint_options
        options = {
          reporters: [
            ["Codeclimate", :stdout]
          ],
          required_paths: [], # the codeclimate report is required above
          files: sanitized_include_paths
        }

        if engine_config["config"]
          options[:config_file] = engine_config["config"]
        end

        options
      end

      def parse_config(config_path)
        File.exists?(config_path) ? JSON.parse(File.read(config_path)) : {}
      end

      def sanitized_include_paths
        valid_extensions = ::SCSSLint::FileFinder::VALID_EXTENSIONS
        include_paths.select do |path|
          path.end_with?("/") || valid_extensions.include?(File.extname(path))
        end
      end

      def include_paths
        engine_config.fetch("include_paths", ["./"])
      end
    end
  end
end
