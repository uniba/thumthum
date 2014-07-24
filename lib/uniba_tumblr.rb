require 'active_support/core_ext'

class UnibaTumblr
  def initialize(tumblr_host, config_path, base_path, json_name = nil)
    @tumblr_host = tumblr_host

    # https://github.com/tumblr/tumblr_client/blob/master/bin/tumblr#L15 を参考
    configuration = YAML.load_file(config_path)
    Tumblr.configure do |config|
      Tumblr::Config::VALID_OPTIONS_KEYS.each do |key|
        config.send(:"#{key}=", configuration[key.to_s])
      end
    end

    @client = Tumblr::Client.new
    unless json_name.nil?
      json_path = "json/#{@tumblr_host}/#{json_name}"
      @data_hash = JSON.parse(File.read(absolute_path(json_path))).symbolize_keys
    end
    @base_path = base_path
  end

  def text
    posted = @client.text(@tumblr_host, @data_hash)
    article_url(posted['id'])
  end

  def photo
    # TODO @data_hashに破壊的な変更をしないためにcopyする。
    @data_hash[:data] = @data_hash[:data].map { |photo_path| absolute_path("json/#{@tumblr_host}/#{photo_path}") }
    posted = @client.photo(@tumblr_host, @data_hash)
    article_url(posted['id'])
  end

  def delete
    posts = fetch_all_posts
    posts.each do |post|
      @client.delete(@tumblr_host, post['id'])
    end
    puts "削除しました"
  end

  def fetch_all_posts
    # https://www.tumblr.com/docs/en/api/v2#posts のoption
    option = {
      limit: 20,
      offset: 0
    }
    all_posts = []

    total_posts = @client.blog_info(@tumblr_host)['blog']['posts']
    until (option[:offset] * option[:limit]) > total_posts
      posts = @client.posts(@tumblr_host, option)
      all_posts << posts['posts']
      option[:offset] += 1
    end
    all_posts.flatten(1)
  end

  private
  
  def absolute_path(relative_path)
    File.expand_path("#{relative_path}", @base_path)
  end

  def article_url(id)
    "http://#{@tumblr_host}/#{id}"
  end
end
