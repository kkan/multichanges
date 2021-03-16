# frozen_string_literal: true

module GithubApi
  module Entity
    class Commit
      attr_reader :sha, :pull_request

      def initialize(sha, pull_request)
        @sha = sha
        @pull_request = pull_request
      end

      def data_request
        @data_request ||= Helper.build_request(['repos', pull_request.repo, 'commits', sha].join('/'))
      end

      def data
        return @data if instance_variable_defined?(:@data)

        data_request.run unless data_request.response
        @data = JSON.parse(@data_request.response.body)
      end

      def files
        @files ||= data['files'].map { |file| CommitFile.new(file['filename'], file['patch']) }
      end
    end
  end
end
