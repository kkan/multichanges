# frozen_string_literal: true

module Proxy
  class List
    def initialize(proxy_url: nil, checker: Checker::Default)
      @proxy_url = proxy_url
      @checker = checker
    end

    def current_proxy
      @current_proxy ||= find_proxy
      @current_proxy = find_proxy unless @current_proxy.works?

      @current_proxy
    end

    private

    def find_proxy
      loop do
        proxy = Wrapper.new(proxy: proxy_enumerator.peek.strip, checker: @checker)
        return proxy if proxy.works?

        proxy_enumerator.next
      end

      Wrapper.new
    end

    def proxy_enumerator
      return @proxy_enumerator if instance_variable_get(:@proxy_enumerator)

      list = Net::HTTP.get(URI(@proxy_url)).split("\n") if @proxy_url

      @proxy_enumerator = Array(list).each
    end
  end
end
