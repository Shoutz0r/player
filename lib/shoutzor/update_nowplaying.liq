# This function will tell the server the next track is playing
def update_nowplaying()
    def log(~level=3,x) = log(level=level,label="update_nowplaying", x) end
    tries = ref(0)
    maxTries = 5
    sleepBetweenTries = 3.

    # Wrap the code in a while-loop to keep retrying on failure
    while !tries < maxTries do
        # Increase the try counter
        tries := !tries + 1

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
                    updateNowplaying: {
                        success: bool,
                        message: string
                    }
                }?,
                errors: [{
                    message: string
                }]?
            }) = "#{http_request}"

            if null.defined(response.data) then
                success = null.get(response.data).updateNowplaying.success

                if success != true then
                    log(level=2,"Update nowplaying failed")
                    error.raise(shoutzor_update_nowplaying_failed, "Failed to update nowplaying")
                else
                    log("Succesfully updated nowplaying")

                    # Not sure if liquidsoap has a "break" operator
                    # therefor just doing this for now to break out of the while loop
                    tries := 100
                end
            else
                log(level=2,"Update nowplaying failed")

                # Check if errors is null
                if null.defined(response.errors) then
                    # Iterate over all errors, and print them
                    list.iter(
                        fun(e) -> log(level=2,e.message),
                        null.get(response.errors)
                    )
                else
                    log(level=2,"Got unexpected response, treating as failed")
                end

                error.raise(shoutzor_update_nowplaying_failed, "Failed to update nowplaying")
            end
        catch err do
            ignore(err)
            
            if !tries < maxTries then
                # If an error is caught, retry up to 3 times to update the "nowplaying"
                log(level=2,"caught error, will retry to update nowplaying")
                log(level=2,"sleeping for #{string_of_float(sleepBetweenTries)} seconds")
                sleep(sleepBetweenTries)
            else
                log(level=1,"Retries exhausted. Failed to update nowplaying")
            end
        end
    end
end