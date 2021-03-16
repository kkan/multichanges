# frozen_string_literal: true

module MultichangedLines
  module Output
    class Stdout
      class << self
        def call(repo, pr_number, result)
          puts "PR #{pr_number}"

          result.each_pair do |filename, data|
            data.each_pair do |line, commits|
              commits.each { |sha| puts make_line_link(repo: repo, sha: sha, filename: filename, line: line) }
            end
          end

          puts "\n\n"
        end

        private

        def make_line_link(repo:, sha:, filename:, line:)
          ['https://github.com', repo, 'blob', sha, filename].join('/') + "#L#{line}"
        end
      end
    end
  end
end
