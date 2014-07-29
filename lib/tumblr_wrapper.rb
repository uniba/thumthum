require 'yaml'
require 'json'
require 'active_support/core_ext'

class TumblrWrapper
  DEFAULT_JSON_PATH = 'lib/data'

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
    @json_name = json_name
    @base_path = base_path
  end

  def text
    if @json_name.nil?
      data_hash = parse_default_data_hash('text')
    else
      puts "@json_name: #{@json_name}"
      data_hash = parse_data_hash('text', @json_name)
    end
    posted = @client.text(@tumblr_host, data_hash)
    article_url(posted['id'])
  end

  def photo
    if @json_name.nil?
      data_hash = parse_default_data_hash('photo')
    else
      data_hash = parse_data_hash('photo', @json_name)
    end
    posted = @client.photo(@tumblr_host, data_hash)
    article_url(posted['id'])
  end

  def delete
    post_ids = fetch_all_post_id
    post_ids.each do |post_id|
      @client.delete(@tumblr_host, post_id)
      puts "delete #{article_url(post_id)}"
    end
    puts "削除が完了しました"
  end

  def fetch_all_post_id
    # https://www.tumblr.com/docs/en/api/v2#posts のoption
    option = {
      limit: 20,
      offset: 0
    }
    all_posts = []

    present_flag = true
    while present_flag
      posts = @client.posts(@tumblr_host, option)['posts']
      present_flag = posts.present?
      next unless present_flag # whileを終了させる
      all_posts << posts
      option[:offset] += 1
    end

    all_posts.flatten!(1)
    all_posts.map! { |post| post['id'] }
    all_posts.uniq!
    all_posts
  end

  private
  
  def absolute_path(relative_path)
    File.expand_path("#{relative_path}", @base_path)
  end

  def article_url(id)
    "http://#{@tumblr_host}/#{id}"
  end

  def parse_default_data_hash(type)
    if type == 'text'
      json_name = "#{DEFAULT_JSON_PATH}/text.json"
    elsif type == 'photo'
      json_name = "#{DEFAULT_JSON_PATH}/photo.json"
    end

    json_path = absolute_path(json_name)
    data_hash = JSON.parse(File.read(absolute_path(json_path))).symbolize_keys
    data_hash[:data] = data_hash[:data].map { |photo_path| absolute_path("#{DEFAULT_JSON_PATH}/#{photo_path}") } if type == 'photo'
    data_hash
  end

  def parse_data_hash(type, json_path)
    json_path = absolute_path(json_path)
    unless File.exist?(json_path)
      puts "#{json_path} は存在しません"
      exit false
    end
    data_hash = JSON.parse(File.read(json_path).to_s.gsub(/[\r\n]/,"")).symbolize_keys
    data_hash[:data] = data_hash[:data].map { |photo_path| File.expand_path("../#{photo_path}", json_path) } if type == 'photo'
    data_hash
  end
end
