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

opts = OptionParser.new
opts.on('-t', '--type', 'text または photo')
params = ARGV.getopts('t:n:u:j:', 'type:', 'number:', 'url:', 'json:', 'delete')

tumblr_host = params['u'] || params['url']
if tumblr_host.nil?
  puts 'tumblrのurlを指定してください'
  puts '例: -u hoge.tumblr.com'
  exit false
end

if /^http/ =~ tumblr_host
  tumblr_host = URI.parse(tumblr_host).host
end

if params['delete']
  uniba_tumblr = UnibaTumblr.new(tumblr_host, config_path, File.expand_path("..", __FILE__))
  uniba_tumblr.delete
  exit
end

type = params['t'] || params['type']

json_name = params['j'] || params['json']
if json_name.nil?
  puts 'jsonのファイル名を指定してください'
  puts '例: -j photo.json'
  exit false
end


num = params['n'] || params['number'] || 1
if num =~ /[^\d+]/
  puts '-n には数字を指定してください'
  puts '例: -n 10'
  exit false
end

num.to_i.times do |i|
  uniba_tumblr = UnibaTumblr.new(tumblr_host, config_path, File.expand_path("..", __FILE__), json_name)
  
  case type
  when 'text'
    article_url = uniba_tumblr.text
  when 'photo'
    article_url = uniba_tumblr.photo
  end
  puts article_url
end
