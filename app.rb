require_relative 'video/video.rb'
require_relative 'video/tts.rb'
require_relative 'video/whispr.rb'

# Define the parameters
input_video_path = 'video/resources/input_video.mp4'
audio_path = 'video/outputs/speech.wav'
image_path = 'image/output.png'
output_video_path = 'video/outputs/output_video.mp4'

# Initialize classes
video_editor = Video.new(input_video_path, output_video_path, audio_path, image_path)
generate_voice = TTS.new
generate_subs = Whispr.new

# Start total timer
total_start_time = Time.now

# Generate subtitles
puts "Generating subtitles"
subs_start_time = Time.now
generate_subs.create_subs()
subs_end_time = Time.now
puts "Subtitles generated in #{subs_end_time - subs_start_time} seconds"

# Generate TTS voice
puts "Generating TTS voice"
tts_start_time = Time.now
generate_voice.generate_voice()
tts_end_time = Time.now
puts "TTS voice generated in #{tts_end_time - tts_start_time} seconds"

# Edit video
puts "Editing video"
video_edit_start_time = Time.now
video_editor.edit_video()
video_edit_end_time = Time.now
puts "Video edited in #{video_edit_end_time - video_edit_start_time} seconds"

# End total timer
total_end_time = Time.now
puts "Total time taken: #{total_end_time - total_start_time} seconds"
