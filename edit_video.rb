# add_text_to_video.rb
require 'streamio-ffmpeg'
require 'mini_magick'

def create_blank_image(output_path, width: 800, height: 600, color: 'black')
  image = MiniMagick::Image.create("png", false) do |f|
    f.write "P3\n#{width} #{height}\n255\n"
    f.write ("#{color == 'black' ? '0 0 0 ' : '255 255 255 '}" * (width * height))
  end
  image.write(output_path)
end

def add_text_to_video(input_video_path, text, output_video_path)
  movie = FFMPEG::Movie.new(input_video_path)
  drawtext_options = "drawtext=text='#{text}':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2"

  movie.transcode(output_video_path, %W(-vf #{drawtext_options}))
end

# Main script execution
if __FILE__ == $0
  if ARGV.length != 3
    puts "Usage: ruby add_text_to_video.rb INPUT_VIDEO_PATH TEXT OUTPUT_VIDEO_PATH"
    exit
  end

  input_video_path = ARGV[0]
  text = ARGV[1]
  output_video_path = ARGV[2]

  # Ensure the input video exists
  unless File.exist?(input_video_path)
    puts "Input video file does not exist: #{input_video_path}"
    exit
  end

  # Add text to video
  add_text_to_video(input_video_path, text, output_video_path)

  puts "Text added to video successfully. Output saved to #{output_video_path}"
end
