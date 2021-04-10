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
unfallibleSource = single("home/liquidsoap/app/resources/fallback.mp4")

#
# the shoutzor.liq file will connect to this
# because of instability that stream might crash sometimes, this way
# it will automatically be able to fix itself without interrupting any stream connections
#

live = input.harbor(
    wrapperInputListeningMount,
    port = wrapperInputListeningPort,
    password = wrapperInputListeningPassword)

live = fallback(
        track_sensitive=false, 
        [live, unfallibleSource])

#
# video output
#
output.icecast(
    mount = wrapperOutputMount,
    id = "videoWrapper",
    host = wrapperOutputHost,
    port = wrapperOutputPort,
    password = wrapperOutputPassword,
    output_format,
    live)