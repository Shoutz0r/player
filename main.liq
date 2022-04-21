%include "config.liq"
%include "functions.liq"

enable_replaygain_metadata()

#Create our unfallible source
safe_source = single("/app/resources/fallback.mp4")
safe_source.log(1)

#Requester input
playlist_source = playlist(
						"/app/playlist.txt",
						id="queue_list",
						mode="randomize",
						reload_mode="seconds",
						reload=0,
						timeout=5.,
						loop=true)

playlist_source = replaygain(playlist_source)

# Apply AutoDJ mixing
playlist_source = autodj_mix(start_next=8., playlist_source)

# Temporary: add video to MP3
temp_video_source = single("/app/resources/fallback.mp4")
playlist_source = mux_video(video=drop_audio(temp_video_source), playlist_source)

# Add the fallback silent unfallible-source and smart crossfade
live = fallback(track_sensitive=false, [playlist_source, safe_source])

#output to wrapper
output.icecast(
  output_format,
  id = "Shoutz0r_main",
  host = wrapper_host,
  port = wrapper_port,
  mount = wrapper_mount,
  password = wrapper_password,
  icy_metadata = "false",
  live)