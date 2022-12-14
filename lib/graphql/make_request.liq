def graphql_make_request(
    ~api=api_graphql_url,
    ~variables={},
    ~headers=[
        ("Content-Type", "application/json"),
        ("User-Agent", "LiquidSoap Shoutzor Player"),
        ("Authorization", api_accesstoken)
    ],
    query
) =
    def log(x) = log(label="graphql_make_request", x) end

    # Build the base json data object
    json_data = json()
    json_data.add("query", query)
    json_data.add("variables", variables)
    
    log("Performing Graphql Request")

    # Execute the GraphQL request
    request = http.post(
        headers=headers,
        data=json_data.stringify(compact=true),
        api
    )

    # Log the HTTP response
    log("Request finished with result code #{request.status_code} and message #{request.status_message}")

    # Check if the response code is a 200 code
    if(request.status_code != 200) then
        # Code was not a 200, throw error
        error.raise(graphql_request_failed, "code: #{request.status_code} | message: #{request.status_message}")
    end

    request
end