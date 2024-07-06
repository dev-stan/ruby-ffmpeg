# gen_title.rb
require 'mini_magick'

# Create a base image with 16:9 aspect ratio (e.g., 1920x1080)
width = 214
height = 135
background_color = "white"
text = "hello world this is a sample reddit title"
font_size = 12
corner_radius = 20  # Adjust the corner radius as needed

# Create a blank image with white background
# image_path = "blank_image.png"
# MiniMagick::Tool::Convert.new do |convert|
#   convert.size "#{width}x#{height}"
#   convert.xc background_color
#   convert << image_path
# end

# Create a rounded rectangle mask
mask_path = "image/rounded_mask.png"
MiniMagick::Tool::Convert.new do |convert|
  convert.size "#{width}x#{height}"
  convert.xc "none"
  convert.fill "gray"
  convert.draw "roundrectangle 0,0,#{width-1},#{height-1},#{corner_radius},#{corner_radius}"
  convert << mask_path
end

# Apply the mask to the image
mask = MiniMagick::Image.open(mask_path)


# Add text to the image
mask.combine_options do |c|
  c.gravity "center"
  c.pointsize font_size
  c.draw "text 0,0 '#{text}'"
  c.fill "black"
end

# Save the image
mask.write "image/output.png"

puts "Image created successfully"
