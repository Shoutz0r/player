# This function will check the current amount of items in the playlist
# and update accordingly to ensure there's always (at least) 2 items in the playlist (including the one being played)
def update_queue()
    def log(x) = log(label="update_queue", x) end

    if playlist_source.length < 2 then
        # We always want at least 2 tracks in the queue.
        # Therefor check how many are currently in the queue (either 0 or 1) and subtract that from 2
        max = 2 - playlist_source.length

        try
            # Attempt making the request
            # Can raise an error if it doesn't return a 200 code
            http_request = graphql_make_request(
                variables={
                    limit = max
                },
                headers=[
                    ("Content-Type", "application/json"),
                    ("User-Agent", "LiquidSoap Shoutzor Player")
                ],
                "query update_queue($limit: Int) {
                    requests(
                        page: 1
                        first: $limit
                        where: {column: PLAYED_AT, operator: IS_NULL}
                    ) {
                        data {
                            media {
                                id
                                filename
                            }
                        }
                    }
                }"
            )

            # Parse the JSON response
            let json.parse (response : {
                data: {
                    requests: {
                        data: [{
                            media: {
                                id: string,
                                filename: string
                            }
                        }]
                    }
                }?,
                errors: [{
                    message: string
                }]?
            }) = "#{http_request}"

            # Check if errors is null
            if null.defined(response.errors) then
                log("Fetch queue failed")

                # Iterate over all errors, and print them
                list.iter(
                    fun(e) -> log(e.message),
                    null.get(response.errors)
                )
            # If there are no errors, return the data from the response
            elsif null.defined(response.data) then
                # Iterate over the resulting requests and add them to the queue
                list.iter(
                    fun(r) -> playlist_source.push(
                        request.create("#{media_storage_path}/#{r.media.filename}")
                    ),
                    null.get(response.data).requests.data
                )

            # Unknown response, return failed
            else
                log("Got unexpected response, doing nothing.")
            end

        catch err do
            print("caught error: #{error.message(err)}")
            log("caught error")
            log(error.message(err))
        end
    end
end