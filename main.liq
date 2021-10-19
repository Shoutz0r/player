%include "config.liq"
%include "functions.liq"

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

# Apply AutoDJ mixing
playlist_source = autodj_mix(start_next=8.,playlist_source)

# Temporary: add video to MP3
temp_video_source = single("/app/resources/fallback.mp4")
playlist_source = mux_video(video=drop_audio(temp_video_source), playlist_source)

# Add the fallback silent unfallible-source and smart crossfade
live = fallback(track_sensitive=false, [playlist_source, safe_source])

#output to wrapper
output.icecast(
  output_format,
  id = "Shoutz0r_main",
  host = "player_wrapper",
  port = wrapperInputListeningPort,
  mount = wrapperInputListeningMount,
  password = wrapperInputListeningPassword,
  icy_metadata = "true",
  live)