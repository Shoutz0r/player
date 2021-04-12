%include "config.liq"
%include "functions.liq"

#Create our unfallible source
silent_source = single("/home/liquidsoap/app/test.mp3")

#Requester input
playlist_source = playlist(
						"/home/liquidsoap/app/playlist.txt",
						id="queue_list",
						mode="randomize",
						reload_mode="seconds",
						reload=0,
						timeout=5.,
						loop=true)

# Apply AutoDJ mixing
playlist_source = autodj_mix(playlist_source)

# Add the fallback silent unfallible-source and smart crossfade
live = add([playlist_source, silent_source])

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