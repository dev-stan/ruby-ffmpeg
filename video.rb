require 'streamio-ffmpeg'
require 'json'

def add_subtitles_audio_and_image_to_video(input_video_path, subtitles, audio_path, image_path, output_video_path)
  movie = FFMPEG::Movie.new(input_video_path)

  # Settings for subtitles
  font_color = 'FFFFFF'
  font_border_color = '000000'
  font_border_width = 5
  increase_font_size_animation = 6

  drawtext_options = subtitles.map do |subtitle|
    subtitle_text = subtitle[:text].gsub("'", "")  # Escape single quotes in the subtitle text

    start = subtitle[:start]
    end_time = subtitle[:end]

    # Drawtext filter with faster animated fontsize for a pop effect
    drawtext_filter = %{
      drawtext=text='#{subtitle_text}':fontcolor=0x#{font_color}:bordercolor=#{font_border_color}:borderw=#{font_border_width}:fontsize='36+#{increase_font_size_animation}*if(between(t,#{start},#{start}+0.1),(t-#{start})*10,if(between(t,#{end_time}-0.1,#{end_time}),(#{end_time}-t)*10,1))':fontfile=resources/font.ttf:box=0:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,#{start},#{end_time})'
    }.strip

    drawtext_filter
  end.join(',')

  # Prepare FFmpeg command with image overlay enabled only for the first 3 seconds
  ffmpeg_command = %W(
    ffmpeg -i #{input_video_path}
    -i #{audio_path}
    -i #{image_path}
    -filter_complex "#{drawtext_options},overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:enable='between(t,0,3)'"
    -map 0:v:0 -map 1:a:0 -c:v libx264 -c:a aac -strict experimental -shortest #{output_video_path}
  ).join(' ')

  # Transcode with subtitles, audio, and image overlay
  system(ffmpeg_command)
end

# Main script execution
input_video_path = 'resources/input_video.mp4'
output_video_path = 'outputs/output_video.mp4'
audio_path = 'outputs/speech.wav'
image_path = 'outputs/output.png'

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

  # Check if the current word's duration is less than 0.2s and there are more words

  # Adjust end time dynamically
  if i < words.length
    group[-1]["end"] = words[i]["start"]  # Set end time of current word to start time of next word
  end

  subtitles << {
    text: group.map { |word| word["word"] }.join(' '),
    start: group.first["start"],
    end: group.last["end"]
  }
end

# Add subtitles, audio, and image overlay to video
add_subtitles_audio_and_image_to_video(input_video_path, subtitles, audio_path, image_path, output_video_path)

puts "Subtitles, audio, and image overlay added to video successfully. Output saved to #{output_video_path}"
