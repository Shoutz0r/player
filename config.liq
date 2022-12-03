# Output Icecast server config values
icecast_host = getenv("ICECAST_SOURCE_SERVER")
icecast_port = int_of_string(getenv("ICECAST_SOURCE_PORT"))
icecast_mount = getenv("ICECAST_SOURCE_MOUNT")
icecast_password = getenv("ICECAST_SOURCE_PASSWORD")

# The output encoding format
output_format = %ffmpeg(
					format="mpegts",
					%audio(
						codec="libmp3lame"),
					%video(
						codec="libx264",
						b="2600k",
						"x264-params"="scenecut=0:open_gop=0:min-keyint=150:keyint=150",
						preset="ultrafast")
				)

#
# use ignore because of warnings
#
ignore(output_format)
ignore(icecast_host)
ignore(icecast_port)
ignore(icecast_mount)
ignore(icecast_password)