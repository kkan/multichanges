# frozen_string_literal: true

require './multichanges'

repo = 'rails/rails'
proxy_list_url = ENV['PROXY_LIST_URL']
proxy_list = Proxy::List.new(proxy_url: proxy_list_url, checker: Proxy::Checker::GithubApi)
requests_helper = RequestsHelper.new(proxy_list: proxy_list)

GithubApi::DataFetcher.fetch_pull_requests(repo, requests_helper) do |pull_requests_array|
  pull_requests = GithubApi::DataFetcher.fetch_pull_requests_data(pull_requests_array, requests_helper)
  pull_requests.select! { |pull_request| pull_request.commits_number > 1 }
  GithubApi::DataFetcher.fetch_commits(pull_requests, requests_helper) do |pr_commits|
    pr_number = pr_commits.first.pull_request.number
    commits = GithubApi::DataFetcher.fetch_commits_data(pr_commits, requests_helper)
    result = MultichangedLines::Finder.call(commits)

    MultichangedLines::Output::Stdout.call(repo, pr_number, result) unless result.empty?
  end
end
