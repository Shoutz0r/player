# Contains all config settings, passwords, etc.
%include "config.liq"
# Contains custom functions
%include "functions.liq"
# Contains any commands
%include "commands.liq"
# Contains the handlers used by functions in main.liq (such as: on_start & on_track)
%include "handlers.liq"

#Create our unfallible source
safe_source = single("/app/resources/fallback.mp4")

#Requester input
playlist_source = request.queue(id="queue")

# Is called whenever liquidsoap is started
def onStart()
    onStartHandler(playlist_source)
end

on_start(onStart)
enable_replaygain_metadata()

# Is called when the source starts playing a new file
def onTrack(m)
  onTrackHandler(playlist_source, m)
end

# Listen to track changes
playlist_source = playlist_source.on_track(onTrack)

playlist_source = replaygain(playlist_source)

# Apply AutoDJ mixing
playlist_source = autodj_mix(
  cross_duration=8., 
  playlist_source)

# Temporary: add video to MP3
temp_video_source = single("/app/resources/fallback.mp4")
playlist_source = mux_video(video=drop_audio(temp_video_source), playlist_source)

# Add the fallback silent unfallible-source and smart crossfade
live = fallback(track_sensitive=false, [playlist_source, safe_source])

#stream output
output.icecast(
  output_format,
  id = "Shoutz0r_main",
  host = icecast_host,
  port = icecast_port,
  mount = icecast_mount,
  password = icecast_password,
  icy_metadata = "false",
  live)