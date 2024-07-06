# gen_title.rb
require 'mini_magick'

# Create a base image with 16:9 aspect ratio (e.g., 1920x1080)
width = 1920
height = 1080
background_color = "white"
text = "hello world this is a sample reddit title"
font_size = 50

# Create a blank image
image_path = "blank_image.png"
# MiniMagick::Tool::Convert.new do |convert|
#   convert.size "#{width}x#{height}"
#   convert.xc background_color
#   convert << image_path
# end

image = MiniMagick::Image.open(image_path)

# Add rounded corners
radius = 50
image.format "png"
image.combine_options do |c|
  c.alpha 'set'
  c.draw "roundrectangle 0,0,#{width-1},#{height-1},#{radius},#{radius}"
  c.fill "red"
end

# Add text to the image
image.combine_options do |c|
  c.gravity "center"
  c.pointsize font_size
  c.draw "text 0,0 '#{text}'"
  c.fill "black"
end

# Save the image
image.write "outputs/output.png"

puts "Image created successfully"
