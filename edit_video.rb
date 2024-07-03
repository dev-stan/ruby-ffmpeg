# add_text_to_video.rb
require 'streamio-ffmpeg'
require 'mini_magick'


def add_subtitles_to_video(input_video_path, subtitles, output_video_path)
  movie = FFMPEG::Movie.new(input_video_path)

  drawtext_options = subtitles.map do |subtitle|
    subtitle_text = subtitle[:text].gsub("'", "\\\\'")  # Escape single quotes in the subtitle text

    start = subtitle[:start]
    end_time = subtitle[:end]

    # Drawtext filter with faster animated fontsize for a pop effect
    drawtext_filter = %{
      drawtext=text='#{subtitle_text}':fontcolor=yellow:fontsize='48+8*if(between(t,#{start},#{start}+0.1),(t-#{start})*10,if(between(t,#{end_time}-0.1,#{end_time}),(#{end_time}-t)*10,1))':fontfile=font.ttf:box=0:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,#{start},#{end_time})'
    }.strip

    drawtext_filter
  end.join(',')

  movie.transcode(output_video_path, %W(-vf #{drawtext_options}))
end

# Main script execution
if __FILE__ == $0

  input_video_path = ARGV[0]
  output_video_path = ARGV[1]

  # Ensure the input video exists
  unless File.exist?(input_video_path)
    puts "Input video file does not exist: #{input_video_path}"
    exit
  end

  # Define subtitles with start and end times
  subtitles = [
    { text: "The aroma", start: 0, end: 0.5 },
    { text: "of freshly", start: 0.5, end: 1 },
    { text: "baked bread", start: 1, end: 1.5 },
    { text: "filled Mayas", start: 1.5, end: 2 },
    { text: "bakery,", start: 2, end: 2.5 },
    { text: "Sunlight", start: 2.5, end: 3 },
    { text: "streamed", start: 3, end: 3.5 },
    { text: "through the", start: 3.5, end: 4 },
    { text: "window,", start: 4, end: 4.5 },
    { text: "illuminating", start: 4.5, end: 5 },
    { text: "rows of", start: 5, end: 5.5 },
    { text: "golden", start: 5.5, end: 6 },
    { text: "loaves,", start: 6, end: 6.5 },
    { text: "Maya,", start: 6.5, end: 7 },
    { text: "flour", start: 7, end: 7.5 },
    { text: "dusting", start: 7.5, end: 8 },
    { text: "her apron,", start: 8, end: 8.5 },
    { text: "carefully", start: 8.5, end: 9 },
    { text: "lifted a", start: 9, end: 9.5 },
    { text: "warm loaf", start: 9.5, end: 10 },
    { text: "from the", start: 10, end: 10.5 },
    { text: "oven,", start: 10.5, end: 11 },
    { text: "A bee", start: 11, end: 11.5 },
    { text: "buzzed by,", start: 11.5, end: 12 },

  ]


  # Add subtitles to video
  add_subtitles_to_video(input_video_path, subtitles, output_video_path)

  puts "Subtitles added to video successfully. Output saved to #{output_video_path}"
end
