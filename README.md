#### Ruby Backend Developer Test Exercise

We believe that commits in a proper pull request stand on their own. There should be no "editing history", meaning that each changed row in each file should only be affected by a single commit only.

Crawl the [https://github.com/rails/rails](rails/rails) github repo and list all the pull requests where there are rows in files affected by multiple commits. Please provide links to the specific rows as well.

#### Notes

Runs several requests to Github API in parallel.

Handling of pull requests with more than 250 commits is not implemented (https://docs.github.com/en/rest/reference/pulls#list-commits-on-a-pull-request), so incorrect result can be returned for such PRs.

### Run

- `bundle install`
- `ruby app.rb`
