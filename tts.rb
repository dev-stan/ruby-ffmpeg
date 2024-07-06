require 'net/http'
require 'uri'
require 'json'

# Replace 'your_openai_api_key' with your actual OpenAI API key.
api_key = ''

uri = URI("https://api.openai.com/v1/audio/speech")

# Prepare the request
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri)
request['Authorization'] = "Bearer #{api_key}"
request['Content-Type'] = 'application/json'

# Set up the request body

script_text = File.open("resources/script.txt", "r").read
body = {
  model: "tts-1",
  input: script_text,
  voice: "onyx"
}
request.body = body.to_json

# Execute the request
response = http.request(request)

# Check the response and save the file if successful
if response.code.to_i == 200
  File.open("outputs/speech.wav", "wb") do |file|
    file.write(response.body)
  end
  puts "Audio saved as 'speech.mp3'."
else
  puts "Error: #{response.code}"
  puts response.body
end
