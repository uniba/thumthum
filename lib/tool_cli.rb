require 'uri'
require 'bundler'
Bundler.require
require './lib/tumblr_wrapper'

class ToolCli < Thor
  desc 'post', 'Post tumblr'
  option :type, aliases: :t, required: true, type: :string
  option :url, aliases: :u, required: true, type: :string
  option :json, aliases: :j, required: true, type: :string
  option :number, aliases: :n, default: 1, type: :numeric
  def post
    config_path = tumblr_config_path
    tumblr_host = parse_host(options[:url])
    options[:number].to_i.times do |i|
      tumblr_wrapper = TumblrWrapper.new(tumblr_host, config_path, app_root_path, options[:json])
      case options[:type]
      when 'text'
        article_url = tumblr_wrapper.text
      when 'photo'
        article_url = tumblr_wrapper.photo
      end
      puts article_url
    end
  end

  desc 'delete', 'Delete all article'
  option :url, aliases: :u, required: true, type: :string
  def delete
    config_path = tumblr_config_path
    tumblr_host = parse_host(options[:url])
    tumblr_wrapper = TumblrWrapper.new(tumblr_host, config_path, app_root_path)
    tumblr_wrapper.delete
  end

  private

  def tumblr_config_path
    config_path = File.join(ENV['HOME'], '.tumblr')
    unless File.exist?(config_path)
      puts 'Readme.mdの「認証」の手順を実行してください'
      exit false
    end
    config_path
  end

  def parse_host(url)
    if /^http/ =~ url
      URI.parse(url).host
    else
      url
    end
  end

  def app_root_path
    File.expand_path('../..', __FILE__)
  end
end
