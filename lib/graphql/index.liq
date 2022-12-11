#
# The main file to be included for the GraphQL library and all it's functions
#

# Include the graphql library files
%include "errors.liq"
%include "parse_result.liq"
%include "make_request.liq"

#
# Will make a graphql request & parse its results
# The result will consist of (success:bool, data)
#
def graphql_request(
    ~query, 
    ~variables={},
    ~api="http://api:8000/graphql"
    ) =
    try
        # Attempt making the request
        # Can raise an error if it doesn't return a 200 code
        request = graphql_make_request(
            variables=variables,
            headers=[
                ("Content-Type", "application/json"),
                ("User-Agent", "LiquidSoap Shoutzor Player")
            ],
            api=api,
            query
        )

        # Parse & Return the results
        parse_graphql_result("#{request}")
    catch err do
        # Error caught, return as failed
        (false, error.message(err))
    end    
end