# Is called whenever liquidsoap is started
def onStartHandler()
    def log(x) = log(label="onStartHandler", x) end
    log("onStart-handler called")

    # First, Update the queue. This should add 2 tracks to the queue (1 to play, 1 in queue)
    thread.run(update_queue)
end

# Is called when the source starts playing a new file
def onTrackHandler(m)
    ignore(m)
    
    def log(x) = log(label="onTrackHandler", x) end
    log("onTrack-handler called")

    # Define the commands to run upon changing tracks
    def changeTracks()
        # First, report to shoutz0r that we have started playing the next track
        update_nowplaying()

        # Next, add a new track to the queue
        update_queue()
    end

    # Run the update from a different thread
    thread.run(changeTracks)    
end

# Checks if the queue requires updating
# For example when the queue has less then 2 tracks
def updateQueueHandler() =
    if playlist_source.length() < 2 then
        update_queue()
    end

    15.
end