# Is called whenever liquidsoap is started
def onStartHandler(source)
    def log(x) = log(label="onStartHandler", x) end
    log("handler called")

    # First, Update the queue. This should add 2 tracks to the queue (1 to play, 1 in queue)
    update_queue()
end

# Is called when the source starts playing a new file
def onTrackHandler(source, m)
    def log(x) = log(label="onTrackHandler", x) end
    log("handler called")

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