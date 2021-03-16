# frozen_string_literal: true

module GithubApi
  module Entity
    class PullRequest
      attr_reader :number, :repo

      def initialize(repo, number)
        @repo = repo
        @number = number
      end

      def data_request
        @data_request ||= Helper.build_request(['repos', repo, 'pulls', number].join('/'))
      end

      def data
        return @data if instance_variable_defined?(:@data)

        data_request.run unless data_request.response
        @data = JSON.parse(@data_request.response.body)
      end

      def commits_number
        data['commits']
      end
    end
  end
end
