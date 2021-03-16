# frozen_string_literal: true

module GithubApi
  class Helper
    MEDIA_TYPE = 'application/vnd.github.v3+json'
    API_ENDPOINT = 'https://api.github.com'
    PER_PAGE = 100

    class << self
      def default_options
        {
          method: :get,
          headers: { accept: MEDIA_TYPE }
        }
      end

      def build_request(path, **options)
        url = [API_ENDPOINT, path].join('/')
        CustomRequest.new(url, default_options.merge(options))
      end
    end
  end
end
