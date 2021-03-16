# frozen_string_literal: true

module GithubApi
  module Entity
    class CommitsPage
      attr_reader :pull_request, :params

      def initialize(pull_request, params)
        @pull_request = pull_request
        @params = params
      end

      def data_request
        url = ['repos', pull_request.repo, 'pulls', pull_request.number, 'commits'].join('/')
        @data_request ||= Helper.build_request(url, params: params)
      end

      def data
        return @data if instance_variable_defined?(:@data)

        data_request.run unless data_request.response
        @data = JSON.parse(@data_request.response.body)
      end

      def commits
        data.map { |commit_entry| Commit.new(commit_entry['sha'], pull_request) }
      end
    end
  end
end
