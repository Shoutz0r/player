%include "config.liq"

#set("log.file.path",                wrapperLogFilePath)
#set("log.stdout",                   wrapperLogStdout)
#set("server.telnet",                wrapperServerTelnet)
#set("server.socket",                wrapperServerSocket)
#set("server.socket.path",           wrapperServerSocketPath)
#set("server.socket.permissions",    wrapperServerSocketPermissions)

#
# In case there is no output
#
unfallibleSource = single("/app/resources/fallback.mp4")

#
# the main.liq file will connect to this
# because of instability that stream might crash sometimes, this way
# it will automatically be able to fix itself without interrupting any stream connections
#
live = input.harbor(
    wrapper_mount,
    port = wrapper_port,
    password = wrapper_password)

# Add the fallback video for when the main player disconnects
live = fallback(track_sensitive=false, [live, unfallibleSource])

#stream output
output.icecast(
    output_format,
    id = "Shoutz0r_wrapper",
    host = icecast_host,
    port = icecast_port,
    mount = icecast_mount,
    password = icecast_password,
    icy_metadata = "true",
    live
)