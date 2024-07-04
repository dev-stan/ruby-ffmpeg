require 'streamio-ffmpeg'
require 'mini_magick'
require 'json'

def add_subtitles_and_audio_to_video(input_video_path, subtitles, audio_path, output_video_path)
  movie = FFMPEG::Movie.new(input_video_path)

  drawtext_options = subtitles.map do |subtitle|
    subtitle_text = subtitle[:text].gsub("'", "")  # Escape single quotes in the subtitle text

    start = subtitle[:start]
    end_time = subtitle[:end]

    # Drawtext filter with faster animated fontsize for a pop effect
    drawtext_filter = %{
      drawtext=text='#{subtitle_text}':fontcolor=yellow:fontsize='48+8*if(between(t,#{start},#{start}+0.1),(t-#{start})*10,if(between(t,#{end_time}-0.1,#{end_time}),(#{end_time}-t)*10,1))':fontfile=resources/font.ttf:box=0:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,#{start},#{end_time})'
    }.strip

    drawtext_filter
  end.join(',')

  # Prepare FFmpeg command
  ffmpeg_command = %W(
    ffmpeg -i #{input_video_path}
    -i #{audio_path}
    -filter_complex "#{drawtext_options}"
    -map 0:v:0 -map 1:a:0 -c:v libx264 -c:a aac -strict experimental -shortest #{output_video_path}
  ).join(' ')

  # Transcode with subtitles and audio
  system(ffmpeg_command)
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

file = File.read('transcription_with_timestamps.json')
data = JSON.parse(file)

# Process the words array
subtitles = data["words"].map do |word|
  {
    text: word["word"],
    start: word["start"],
    end: word["end"]
  }
end

# Add subtitles and audio to video
add_subtitles_and_audio_to_video(input_video_path, subtitles, audio_path, output_video_path)

puts "Subtitles and audio added to video successfully. Output saved to #{output_video_path}"
