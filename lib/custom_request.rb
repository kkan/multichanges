# frozen_string_literal: true

class CustomRequest < Typhoeus::Request
  def cache_key
    Digest::SHA1.hexdigest "#{self.class.name}#{base_url}#{hashable_string_for(options_for_cache_key)}"
  end

  def options_for_cache_key
    options.slice(*(options.keys - %i[proxy proxyauth proxyuserpwd]))
  end
end
