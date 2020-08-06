%include "config.liq"

set("log.file.path",                wrapperLogFilePath)
set("log.stdout",                   wrapperLogStdout)
set("server.telnet",                wrapperServerTelnet)
set("server.socket",                wrapperServerSocket)
set("server.socket.path",           wrapperServerSocketPath)
set("server.socket.permissions",    wrapperServerSocketPermissions)

#
# In case there is no output
#
unfallibleSource = single("./resources/fallback.mp4")

#
# the shoutzor.liq file will connect to this
# because of instability that stream might crash sometimes, this way
# it will automatically be able to fix itself without interrupting any stream connections
#

liveVideo = input.harbor(
    wrapperInputListeningMount,
    port = wrapperInputListeningPort,
    password = wrapperInputListeningPassword)

liveVideo = fallback(track_sensitive=false, [liveVideo, unfallibleSource])
liveAudio = drop_video(liveVideo)

#
# audio output
#
output.icecast(
  audioEncodingFormat,
  mount = wrapperAudioOutputMount,
  id = "audioWrapper",
  host = wrapperAudioOutputHost,
  port = wrapperAudioOutputPort,
  password = wrapperAudioOutputPassword,
  liveAudio)

#
# video output
#
output.icecast(
  videoEncodingFormat,
  mount = wrapperVideoOutputMount,
  id = "videoWrapper",
  host = wrapperVideoOutputHost,
  port = wrapperVideoOutputPort,
  password = wrapperVideoOutputPassword,
  liveVideo)