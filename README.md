## Make social media video with ruby

This is a simple script made with `streamio-ffmpeg` used to generate short-form content that includes:
- background image
- AI voiceover
- subtitles

## Run

Make sure you have Ruby installed, minimum version is `3.1.2`
An `.env` file with your `OPEANAI_API_KEY` variable is required.

Order of files to run:

- `ruby tts.rb`
- `ruby whispr.rb`
- `ruby video.rb`
