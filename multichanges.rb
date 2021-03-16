# frozen_string_literal: true

require 'cgi'
require 'json'
require 'net/http'
require 'redis'
require 'octokit'
require 'git_diff_parser'
require 'typhoeus'
require 'typhoeus/cache/redis'

Dir[File.join(__dir__, 'lib', '**', '*.rb')].sort.each { |file| require file }

$redis = Redis.new
Typhoeus::Config.cache = Typhoeus::Cache::Redis.new($redis)
