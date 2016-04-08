module SCSSLint
  class Reporter::CodeclimateReporter < Reporter

    def report_lints
      lints.each do |lint|
        linter_name = lint.linter ? lint.linter.name : "Error"
        issue_json = {
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
        $stdout.print("#{issue_json}\0")
      end
      nil
    end

  end
end
