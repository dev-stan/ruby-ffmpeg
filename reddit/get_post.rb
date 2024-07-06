require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

# Constants from environment variables
CLIENT_ID = ENV['REDDIT_CLIENT_ID']
SECRET = ENV['REDDIT_SECRET']
USER_AGENT = 'RubyScript/1.0'

AUTH_URL = 'https://www.reddit.com/api/v1/access_token'

# Function to fetch and print the content of a specific Reddit post by its ID
def fetch_reddit_post(post_id)
  token = get_token

  # Construct API URL to fetch a specific Reddit post by its ID
  post_url = "https://oauth.reddit.com/api/info/?id=t3_#{post_id}"
  uri = URI(post_url)
  req = Net::HTTP::Get.new(uri)
  req['Authorization'] = "Bearer #{token}"
  req['User-Agent'] = USER_AGENT

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  if res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    post = data['data']['children'][0]['data']  # Extracting the post data
    puts post['selftext']  # Outputting the post content
  else
    puts "Failed to fetch Reddit post. HTTP #{res.code}"
  end

  post['selftext']
end

# Function to obtain OAuth token using client credentials flow
def get_token
  uri = URI(AUTH_URL)
  req = Net::HTTP::Post.new(uri)
  req.basic_auth(CLIENT_ID, SECRET)
  req.set_form_data('grant_type' => 'client_credentials')
  req['User-Agent'] = USER_AGENT

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  JSON.parse(res.body)['access_token']
end

# Example usage: Fetch and print content of a specific Reddit post
# Replace 'reddit_post_id' with the actual Reddit post ID you want to fetch

File.open('video/resources/script.txt', 'w') { |file| file.write(fetch_reddit_post('1d43rgs')) }
