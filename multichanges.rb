# frozen_string_literal: true

require 'octokit'
require 'git_diff_parser'
require 'cgi'
require 'net/http'
require 'typhoeus'
require 'typhoeus/cache/redis'
require 'redis'
require 'csv'
require 'json'

require 'pry'
require 'benchmark'

Dir[File.join(__dir__, 'lib', '**', '*.rb')].sort.each { |file| require file }

$redis = Redis.new
Typhoeus::Config.cache = Typhoeus::Cache::Redis.new($redis)
