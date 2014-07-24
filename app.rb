require 'yaml'
require 'optparse'
require 'uri'
require 'json'
require 'bundler'
Bundler.require

require './lib/uniba_tumblr'

# bundle exec tumblr で作成したconfigファイルを指定
config_path = File.join(ENV['HOME'], '.tumblr')
unless File.exist?(config_path)
  puts 'Readme.mdの「認証」の手順を実行してください'
  exit false
end

params = ARGV.getopts('t:n:u:j:', 'type:', 'number:', 'url:', 'json', 'd')
type = params['t'] || type['type']
# TODO 複数投稿
# num = params['n'] || type['number'] || 1
tumblr_host = params['u'] || params['url']

if tumblr_host.nil?
  puts 'tumblrのurlを指定してください'
  puts '例: -u hoge.tumblr.com'
  exit false
end

if /^http/ =~ tumblr_host
  tumblr_host = URI.parse(tumblr_host).host
end

json_name = params['j'] || params['json']
if json_name.nil?
  puts 'jsonのファイル名を指定してください'
  puts '例: -j photo.json'
  exit false
end

uniba_tumblr = UnibaTumblr.new(tumblr_host, config_path, json_name, File.expand_path("..", __FILE__))

case type
when 'text'
  article_url = uniba_tumblr.text
when 'photo'
  article_url = uniba_tumblr.photo
end
puts article_url
