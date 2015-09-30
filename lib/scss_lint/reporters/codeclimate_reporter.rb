module SCSSLint
  class Reporter::CodeclimateReporter < Reporter

    def report_lints
      lints.map do |lint|
        linter_name = lint.linter ? lint.linter.name : "Error"
        {
          type: "issue",
          check_name: linter_name,
          description: lint.description,
          categories: ["Style"],
          remediation_points: 50_000,
          location: {
            path: lint.filename,
            positions: {
              begin: {
                line: lint.location.line,
                column: lint.location.column
              },
              end: {
                line: lint.location.line,
                column: lint.location.column + lint.location.length - 1
              }
            }
          }
        }.to_json
      end.join("\0")
    end

  end
end
