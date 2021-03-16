# frozen_string_literal: true

module Proxy
  class Wrapper
    CACHE_TIME_PROXY = 3600

    def initialize(proxy: nil, checker: ProxyChecker::Default)
      @proxy = proxy
      @checked = false
      @checker = checker
    end

    def proxy_options
      return {} unless @proxy

      @proxy_options ||= { proxy: @proxy }
    end

    def check!
      if bad_proxy?
        @checked = true
        return @works = false
      end

      result = @checker.call(proxy_options)

      @checked = true
      @rate_limit_remaining = result[:rate_limit_remaining] || Float::INFINITY
      @rate_limit_reset_left = result[:rate_limit_reset_left]
      @works = result[:success]
    end

    def works?
      check! unless @checked

      @works
    end

    def rate_limit_remaining=(value)
      @rate_limit_remaining = value
      if @rate_limit_remaining < 1
        @works = false
        cache_bad_proxy!
      end

      @rate_limit_remaining
    end

    def rate_limit_remaining
      check! unless @checked

      @rate_limit_remaining
    end

    private

    def bad_proxy?
      !!$redis&.exists?(bad_proxy_cache_key)
    end

    def cache_bad_proxy!
      options = { ex: (@rate_limit_reset_left || CACHE_TIME_PROXY) }

      $redis&.set(bad_proxy_cache_key, true, **options)
    end

    def bad_proxy_cache_key
      "bad_proxy:#{@checker}-#{@proxy.to_s.gsub(':', '-')}"
    end
  end
end
