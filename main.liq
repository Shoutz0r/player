%include "config.liq"
%include "autodj.liq"

# Generate our dummy file to copy the audio/video tracks from when processing tracks
process.run("ffmpeg -f lavfi -i color -f lavfi -i anullsrc -ac 1 -ar 8000 -t 5 /tmp/shoutz0r/dummy.webm")

# Custom protocol, when a file gets loaded it will check the audio/video tracks (and add them if they are missing)
def shoutzor_protocol(
	~rlog,
	~maxtime,
	arg) =
	extname = file.extension(leading_dot=false,dir_sep="/",arg)
	[process_uri(extname=extname,uri=arg,"ffmpeg -i $(input) -stream_loop -1 -i /tmp/shoutz0r/dummy.webm -c copy -shortest $(output)")]
end

add_protocol(
	temporary=false,
	static=true,
	syntax="shoutzor://filepath",
	doc="Fetches requested file from Shoutz0r",
	"shoutzor",
	shoutzor_protocol)

#Create our unfallible source
silent_source = single("/home/liquidsoap/app/resources/fallback_with_audio.mp4")

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