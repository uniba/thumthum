require 'active_support/core_ext'

class UnibaTumblr
  def initialize(tumblr_host, config_path, json_name, base_path)
    @tumblr_host = tumblr_host

    # https://github.com/tumblr/tumblr_client/blob/master/bin/tumblr#L15 を参考
    configuration = YAML.load_file(config_path)
    Tumblr.configure do |config|
      Tumblr::Config::VALID_OPTIONS_KEYS.each do |key|
        config.send(:"#{key}=", configuration[key.to_s])
      end
    end

    @client = Tumblr::Client.new
    json_path = "json/#{@tumblr_host}/#{json_name}"
    @data_hash = JSON.parse(File.read(absolute_path(json_path))).symbolize_keys
    @base_path = base_path
  end

  def text
    posted = @client.text(@tumblr_host, @data_hash)
    article_url(posted['id'])
  end

  def photo
    @data_hash[:data] = @data_hash[:data].map { |photo_path| absolute_path("json/#{@tumblr_host}/#{photo_path}") }
    posted = @client.photo(@tumblr_host, @data_hash)
    article_url(posted['id'])
  end

  private
  
  def absolute_path(relative_path)
    File.expand_path("#{relative_path}", @base_path)
  end

  def article_url(id)
    "http://#{@tumblr_host}/#{id}"
  end
end
