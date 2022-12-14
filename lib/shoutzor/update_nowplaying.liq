# This function will tell the server the next track is playing
def update_nowplaying()
    def log(x) = log(label="update_nowplaying", x) end
    tries = ref(0)
    maxTries = 5
    sleepBetweenTries = 3.

    # Wrap the code in a while-loop to keep retrying on failure
    while !tries < maxTries do
        # Increase the try counter
        tries := tries + 1

        # Attempt updating the nowplaying
        try
            # Attempt making the request
            # Can raise an error if it doesn't return a 200 code
            http_request = graphql_make_request(
                "mutation update_nowplaying {
                    updateNowplaying {
                        success
                        message
                    }
                }"
            )

            # Parse the JSON response
            let json.parse (response : {
                data: {
                    success: bool,
                    message: string
                }?,
                errors: [{
                    message: string
                }]?
            }) = "#{http_request}"


            if null.defined(response.data) then
                success = null.get(response.data).success

                if !success then
                    log.important("Update nowplaying failed")
                    error.raise(shoutzor_update_nowplaying_failed, "Failed to update nowplaying")
                else
                    log("Succesfully updated nowlaying")

                    # Not sure if liquidsoap has a "break" operator
                    # therefor just doing this for now to break out of the while loop
                    tries := 100
                end
            else
                log.important("Update nowplaying failed")

                # Check if errors is null
                if null.defined(response.errors) then
                    # Iterate over all errors, and print them
                    list.iter(
                        fun(e) -> log.important(e.message),
                        null.get(response.errors)
                    )
                else
                    log.important("Got unexpected response, treating as failed")
                end

                error.raise(shoutzor_update_nowplaying_failed, "Failed to update nowplaying")
            end
        catch err do
            if !tries < maxTries then
                # If an error is caught, retry up to 3 times to update the "nowplaying"
                log.important("caught error, will retry to update nowplaying")
                log.important("sleeping for #{string_of_float(sleepBetweenTries)} seconds")
                sleep(sleepBetweenTries)
            else
                log.critical("Retries exhausted. Failed to update nowplaying")
            end
        end
    end
end