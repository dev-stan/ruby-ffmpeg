require 'streamio-ffmpeg'
require 'json'

def add_subtitles_and_audio_to_video(input_video_path, subtitles, audio_path, output_video_path)
  movie = FFMPEG::Movie.new(input_video_path)
  audio = FFMPEG::Movie.new(audio_path)

  # Create a new movie with subtitles and audio
  movie.subtitles = subtitles.map do |subtitle|
    FFMPEG::Subtitle.new(
      subtitle[:text],
      font: 'resources/font.ttf',
      fontcolor: 'FFFFFF',
      fontsize: 36,
      bordercolor: '000000',
      borderwidth: 5,
      start_time: subtitle[:start],
      end_time: subtitle[:end]
    )
  end

  movie.add_audio(audio)  # Add audio stream to the movie

  movie.transcode(output_video_path, { custom: %w(-c:v libx264 -c:a aac -strict experimental -shortest) })
end

# Main script execution
input_video_path = 'resources/input_video.mp4'
output_video_path = 'outputs/output_video.mp4'
audio_path = 'outputs/speech.wav'

# Ensure the input video exists
unless File.exist?(input_video_path)
  puts "Input video file does not exist: #{input_video_path}"
  exit
end

file = File.read('outputs/transcription_with_timestamps.json')
data = JSON.parse(file)

# Process the words array
subtitles = []
words = data["words"]

i = 0
while i < words.length
  if i + 1 < words.length && words[i]["word"].length < 3 && words[i + 1]["word"].length >= 3
    # Include the next word if the current word's length < 3
    group = [words[i], words[i + 1]]
    i += 2  # Move to the next pair
  else
    # Otherwise, just include the current word
    group = [words[i]]
    i += 1  # Move to the next word
  end

  # Adjust end time dynamically
  if i < words.length
    group[-1]["end"] = words[i]["start"]  # Set end time of current word to start time of next word
  end

  subtitles << {
    text: group.map { |word| word["word"] }.join(' '),
    start: group.first["start"].to_f,
    end: group.last["end"].to_f
  }
end

# Add subtitles and audio to video
add_subtitles_and_audio_to_video(input_video_path, subtitles, audio_path, output_video_path)

puts "Subtitles and audio added to video successfully. Output saved to #{output_video_path}"
