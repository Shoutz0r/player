%include "config.liq"
%include "functions.liq"
%include "commands.liq"

def metadatahandler(m)
  #http.get("/api/")
end

enable_replaygain_metadata()

#Create our unfallible source
safe_source = single("/app/resources/fallback.mp4")

#Requester input
playlist_source = playlist(
						"/app/playlist.txt",
						id="queue_list",
						mode="randomize",
						reload_mode="seconds",
						reload=0,
						timeout=5.,
						loop=true)

# Listen to track changes
on_track(onTrackHandler, playlist_source)

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