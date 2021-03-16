# frozen_string_literal: true

module GithubApi
  module Entity
    class PullRequestsPage
      attr_reader :repo, :params

      def initialize(repo, params)
        @repo = repo
        @params = params
      end

      def data_request
        @data_request ||= Helper.build_request(['repos', repo, 'pulls'].join('/'), params: params)
      end

      def data
        return @data if instance_variable_defined?(:@data)

        data_request.run unless data_request.response
        @data = JSON.parse(@data_request.response.body)
      end

      def pull_requests
        data.map { |pull_request_entry| PullRequest.new(repo, pull_request_entry['number']) }
      end
    end
  end
end
