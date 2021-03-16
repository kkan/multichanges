# frozen_string_literal: true

module GithubApi
  module Entity
    class CommitFile
      attr_reader :filename, :patch

      def initialize(filename, patch)
        @filename = filename
        @patch = patch
      end

      def changed_line_numbers
        @changed_line_numbers ||= GitDiffParser::Patch.new(patch).changed_line_numbers
      end
    end
  end
end
