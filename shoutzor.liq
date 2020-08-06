%include "config.liq"
%include "functions.liq"
%include "commands.liq"

set("log.file.path",                shoutzorLogFilePath)
set("log.stdout",                   shoutzorLogStdout)
set("server.telnet",                shoutzorServerTelnet)
set("server.socket",                shoutzorServerSocket)
set("server.socket.path",           shoutzorServerSocketPath)
set("server.socket.permissions",    shoutzorServerSocketPermissions)

set("audio.converter.samplerate.libsamplerate.quality", "best")

def metadatahandler(m)
	system("curl #{shoutzorUrl}/api/nexttrack &")
end

#Create our unfallible source
silent_source = single("./resources/video_fallback.mkv")

#Requester input
#Change reload_mode to "watch" if we are going to use a local (generated) playlist file
live = playlist("my_playlist_location.m3u",id="shoutzorqueue",reload_mode="seconds",reload=5)

# Add the fallback silent unfallible-source and smart crossfade
live = fallback(
  track_sensitive=false,
  [
    smart_crossthing(
    	start_next=5., 
    	fade_out=7., 
    	fade_in=5., 
    	conservative=true, 
    	live
    ),
    silent_source
  ]
)

# Attach a skip command to the source input:
add_skip_command(live)

# Trigger an API call when the next track is played to update the playlist / queue
on_track(metadatahandler, live)

#stream output
output.icecast(
  videoEncodingFormat,
  mount = wrapperInputListeningMount,
  id = "shoutzor",
  host = "localhost",
  port = wrapperInputListeningPort,
  password = wrapperInputListeningPassword,
  live)