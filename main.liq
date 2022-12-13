# Contains all config settings, passwords, etc.
%include "config.liq"
# Contains custom functions
%include "functions.liq"
# Contains any commands
%include "commands.liq"
# Contains the handlers used by functions in main.liq (such as: on_start & on_track)
%include "handlers.liq"

# Prevents sudden changes in loudness
enable_replaygain_metadata()

#Create our unfallible source
safe_source = single("/app/resources/fallback.mp4")

#Requester input
playlist_source = request.queue(id="queue")

# Is called whenever liquidsoap is started
on_start(fun() -> onStartHandler(playlist_source))

# Listen to track changes
playlist_source = playlist_source.on_track(fun(m) -> onTrackHandler(playlist_source, m))

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