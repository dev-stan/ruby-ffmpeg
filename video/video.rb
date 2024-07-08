require 'streamio-ffmpeg'
require 'json'
require 'tempfile'

class Video
  def initialize(input_video_path, output_video_path, audio_path, image_path)
    @input_video_path = input_video_path
    @output_video_path = output_video_path
    @audio_path = audio_path
    @image_path = image_path
  end

  def edit_video()
    subtitles = create_subs()
    movie = FFMPEG::Movie.new(@input_video_path)

    # Settings for subtitles
    default_font_color = 'FFFFFF'
    highlight_font_color = 'FF0000'
    font_border_color = '000000'
    font_border_width = 5
    increase_font_size_animation = 6

    drawtext_options = subtitles.map.with_index do |subtitle, index|
      start = subtitle[:start]
      end_time = subtitle[:end]

      # Create separate drawtext filters for each word in the subtitle
      word_filters = subtitle[:words].map.with_index do |word, word_index|
        word_text = word[:text].gsub("'", "")  # Escape single quotes
        word_start = word[:start]
        word_end = word[:end]

        base_options = "fontfile=video/resources/font.ttf:fontsize='36+#{increase_font_size_animation}*if(between(t,#{start},#{start}+0.1),(t-#{start})*10,if(between(t,#{end_time}-0.1,#{end_time}),(#{end_time}-t)*10,1))':box=0:boxcolor=black@0.5:boxborderw=5:x=(w-tw)/2+tw*#{word_index}:y=(h-th)/2"

        # Normal state (white text)
        normal = "drawtext=text='#{word_text}':fontcolor=0x#{default_font_color}:bordercolor=#{font_border_color}:borderw=#{font_border_width}:#{base_options}:enable='between(t,#{start},#{end_time})*not(between(t,#{word_start},#{word_end}))'"

        # Highlighted state (red text)
        highlighted = "drawtext=text='#{word_text}':fontcolor=0x#{highlight_font_color}:bordercolor=#{font_border_color}:borderw=#{font_border_width}:#{base_options}:enable='between(t,#{word_start},#{word_end})'"

        "#{normal},#{highlighted}"
      end

      word_filters.join(',')
    end.join(',')

    # Write complex filter to a temporary file
    filter_file = Tempfile.new(['ffmpeg_filter', '.txt'])
    filter_file.write("#{drawtext_options},overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:enable='between(t,0,3)'")
    filter_file.close

    # Prepare FFmpeg command using the filter file
    ffmpeg_command = %W(
      ffmpeg -i #{@input_video_path}
      -i #{@audio_path}
      -i #{@image_path}
      -filter_complex_script #{filter_file.path}
      -map 0:v:0 -map 1:a:0 -c:v libx264 -c:a aac -strict experimental -shortest #{@output_video_path}
    )

    # if output video already exists, delete it
    File.delete(@output_video_path) if File.exist?(@output_video_path)

    # Run the command
    system(*ffmpeg_command)

    # Clean up the temporary file
    filter_file.unlink
  end

  private

  def create_subs
    file = File.read('video/outputs/transcription_with_timestamps.json')
    data = JSON.parse(file)

    subtitles = []
    words = data["words"]

    i = 0
    while i < words.length
      if i + 1 < words.length && words[i]["word"].length < 3 && words[i + 1]["word"].length >= 3
        group = [words[i], words[i + 1]]
        i += 2
      else
        group = [words[i]]
        i += 1
      end

      if i < words.length
        group[-1]["end"] = words[i]["start"]
      end

      subtitles << {
        text: group.map { |word| word["word"] }.join(' '),
        start: group.first["start"],
        end: group.last["end"],
        words: group.map { |word| { text: word["word"], start: word["start"], end: word["end"] } }
      }
    end

    subtitles
  end
end
