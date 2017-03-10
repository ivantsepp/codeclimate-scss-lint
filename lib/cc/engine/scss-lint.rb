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

        Dir.chdir(directory) do
          if (scss_lint_config = cli.send(:setup_configuration, options)).scss_files.any?
            user_specified_scss_files = ::SCSSLint::FileFinder.new(scss_lint_config).find(scss_lint_config.scss_files)
            options[:files] = filter_by_sanitized_include_paths(user_specified_scss_files)
          end
        end

        options
      end

      def filter_by_sanitized_include_paths(files)
        files.select do |file|
          file.start_with?(*sanitized_include_paths)
        end
      end

      def parse_config(config_path)
        File.exists?(config_path) ? JSON.parse(File.read(config_path)) : {}
      end

      def sanitized_include_paths
        return @sanitized_include_paths unless @sanitized_include_paths.nil?

        valid_extensions = ::SCSSLint::FileFinder::VALID_EXTENSIONS
        @sanitized_include_paths = include_paths.select do |path|
          path.end_with?("/") || valid_extensions.include?(File.extname(path))
        end
      end

      def include_paths
        engine_config.fetch("include_paths", ["./"])
      end
    end
  end
end
