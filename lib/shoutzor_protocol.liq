#
# This will be used as a workaround until something like a "has_video" method is implemented
# Until then, we will need a separate way to detect if the file is audio-only or audio+video.
#

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