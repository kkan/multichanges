# frozen_string_literal: true

module Proxy
  module Checker
    class GithubApi
      API_ENDPOINT = 'https://api.github.com'
      MEDIA_TYPE = 'application/vnd.github.v3+json'
      DEFAULT_RESET_TIME = 3600
      DEFAULT_TIMEOUT = 5

      def self.call(proxy_options)
        request_options = { headers: { accept: MEDIA_TYPE }, cache: false, timeout: DEFAULT_TIMEOUT, **proxy_options }
        response = CustomRequest.get(API_ENDPOINT, request_options)
        rate_limit_remaining = response.headers['x-ratelimit-remaining']&.to_i

        {
          success: response.success?,
          rate_limit_remaining: rate_limit_remaining,
          rate_limit_reset_left: get_rate_limit_reset_left(response)
        }.compact
      end

      def self.get_rate_limit_reset_left(response)
        reset_time = response.headers['x-ratelimit-reset']&.to_i
        (Time.at(reset_time) - Time.now).round if reset_time
      end
    end
  end
end
