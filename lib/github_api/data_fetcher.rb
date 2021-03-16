# frozen_string_literal: true

module GithubApi
  class DataFetcher
    class << self
      def fetch_pull_requests(repo, requests_helper = RequestsHelper.new)
        params = { state: :all, per_page: Helper::PER_PAGE, sort: :created, direction: :asc, page: 1 }
        pages_number = total_pages(:pull_requests, repo, params)

        (1..pages_number).each_slice(requests_helper.class::MAX_CONCURRENCY) do |group|
          requests = []

          pull_request_pages = group.map do |page|
            Entity::PullRequestsPage.new(repo, params.merge(page: page)).tap do |pull_request_page|
              requests << pull_request_page.data_request
            end
          end

          requests_helper.batch_requests_run(requests)

          pull_request_pages.each { |pull_request_page| yield(pull_request_page.pull_requests) if block_given? }
        end
      end

      def fetch_commits(pull_requests, requests_helper = RequestsHelper.new)
        params = { per_page: Helper::PER_PAGE }

        pull_requests.each_slice(requests_helper.class::MAX_CONCURRENCY) do |group|
          commits_pages_groups = group.reduce([]) do |result, pull_request|
            pages = [(pull_request.commits_number / params[:per_page].to_f).ceil, 3].min

            result << (1..pages).map { |page| Entity::CommitsPage.new(pull_request, params.merge(page: page)) }
          end

          requests = commits_pages_groups.flatten.map(&:data_request)
          requests_helper.batch_requests_run(requests)

          commits_pages_groups.each do |commits_pages_group|
            pr_commits = commits_pages_group.map(&:commits).flatten
            yield(pr_commits) if block_given?
          end
        end
      end

      def fetch_pull_requests_data(pull_requests, requests_helper = RequestsHelper.new)
        puts "Processing pull requests #{pull_requests.first.number}-#{pull_requests.last.number}"

        pull_requests.each_slice(requests_helper.class::MAX_CONCURRENCY) do |group|
          requests = group.map(&:data_request)
          requests_helper.batch_requests_run(requests)
        end

        pull_requests
      end

      def fetch_commits_data(commits, requests_helper = RequestsHelper.new)
        commits.each_slice(requests_helper.class::MAX_CONCURRENCY) do |group|
          requests = group.map(&:data_request)
          requests_helper.batch_requests_run(requests)
        end

        commits
      end

      def total_pages(method_name, repo, params)
        client = Octokit::Client.new
        client.public_send(method_name, repo, params)
        last_page_url = client.last_response.rels[:last].href

        CGI.parse(URI.parse(last_page_url).query)['page'][0].to_i
      end
    end
  end
end
