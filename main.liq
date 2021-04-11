%include "config.liq"
%include "functions.liq"

#Create our unfallible source
silent_source = single("/home/liquidsoap/app/test.mp3")

#Requester input
playlist_source = playlist("/home/liquidsoap/app/playlist.txt",id="queue_list",reload_mode="seconds",reload=10,timeout=5.)

#video_source = drop_audio(playlist_source)

# Add the fallback silent unfallible-source and smart crossfade
live = add([playlist_source, silent_source])

#live = ffmpeg.encode.audio_video(output_format, live)

#stream output
output.srt(
	id = "test_output",
	mode = "listener",
	host = "localhost",
	port = 8000,
	bind_address = "0.0.0.0",
	output_format,
	fallible = true,
	live
)