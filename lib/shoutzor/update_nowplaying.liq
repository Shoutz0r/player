# This function will tell the server the next track is playing
def update_nowplaying()
    def log(x) = log(label="update_nowplaying", x) end

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
            "mutation update_nowplaying($limit: Int) {
                requests(
                    page: 1
                    first: $limit
                    where: {column: PLAYED_AT, operator: IS_NULL}
                ) {
                    data {
                        media {
                            filename
                        }
                    }
                }
            }"
        )
    catch err do
        print("caught error: #{error.message(err)}")
        log("caught error")
        log(error.message(err))
    end
end