# frozen_string_literal: true

module MultichangedLines
  class Finder
    class << self
      def call(commits)
        aggregate_changes(commits).map do |name, lines|
          multichanged_lines = lines.select { |_line_number, refs| refs.size > 1 }
          [name, multichanged_lines] if multichanged_lines.size.positive?
        end.compact.to_h
      end

      private

      def aggregate_changes(commits)
        commits.each_with_object({}) do |commit, files|
          commit.files.each do |file|
            files[file.filename] ||= {}
            file.changed_line_numbers.each do |line_number|
              files[file.filename][line_number] ||= []
              files[file.filename][line_number] << commit.sha
            end
          end
        end
      end
    end
  end
end
