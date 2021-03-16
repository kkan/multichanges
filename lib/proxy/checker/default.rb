# frozen_string_literal: true

module Proxy
  module Checker
    class Default
      URL = 'https://fast.com/'
      DEFAULT_TIMEOUT = 5

      def self.call(proxy_options)
        response = CustomRequest.get(URL, timeout: DEFAULT_TIMEOUT, cache: false, **proxy_options)

        { success: response.success? }
      end
    end
  end
end
