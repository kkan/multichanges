# frozen_string_literal: true

class RequestsHelper
  MAX_CONCURRENCY = 59

  def initialize(proxy_list: ProxyList.new)
    @proxy_list = proxy_list
  end

  def batch_requests_run(requests)
    requests_to_run = requests

    loop do
      run_requests(requests_to_run)
      requests_to_run = select_failed_requests(requests_to_run) { |request| clear_typhoeus_cache(request) }

      break if requests_to_run.size.zero?
    end

    requests
  end

  private

  def current_proxy
    @proxy_list.current_proxy
  end

  def run_requests(requests)
    hydra = Typhoeus::Hydra.new(max_concurrency: MAX_CONCURRENCY)

    requests.each do |request|
      unless cached?(request)
        request.options.merge!(current_proxy.proxy_options)
        current_proxy.rate_limit_remaining -= 1
      end

      hydra.queue(request)
    end

    hydra.run
  end

  def select_failed_requests(requests)
    requests.select do |request|
      next if request.response.success? && request.response.body.size.positive?

      yield(request) if block_given?

      true
    end
  end

  def clear_typhoeus_cache(request)
    typhoeus_redis_cache&.expire(request.cache_key, 0)
  end

  def cached?(request)
    !!typhoeus_redis_cache&.exists?(request.cache_key)
  end

  def typhoeus_redis_cache
    Typhoeus::Config.cache.instance_variable_get(:@redis)
  end
end
