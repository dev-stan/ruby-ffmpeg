require 'net/http'
require 'uri'
require 'json'
require 'mime/types'

# Your API key
require 'dotenv/load'

class Whispr
  def create_subs
    api_key = ENV['OPENAI_API_KEY']

    # Path to the audio file
    puts 'Getting audio file path'
    audio_file_path = 'video/outputs/speech.wav'

    # Prepare the request
    puts 'Preparing the request'
    uri = URI.parse('https://api.openai.com/v1/audio/transcriptions')
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request.set_form(
      [
        ['file', File.open(audio_file_path)],
        ['timestamp_granularities[]', 'word'],
        ['model', 'whisper-1'],
        ['response_format', 'verbose_json']
      ],
      'multipart/form-data'
    )
    puts 'Sending the request'
    # Send the request
    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    puts 'Getting response'
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts 'Response received'
    # Parse the response
    response_body = JSON.parse(response.body)
    puts 'Response parsed'
    # Save the response to a JSON file
    File.open('video/outputs/transcription_with_timestamps.json', 'w') do |file|
      file.write(JSON.pretty_generate(response_body))
    end
    puts 'File saved'
  end
end
