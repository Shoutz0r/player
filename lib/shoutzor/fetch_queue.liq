# This command will query the backend GraphQL API to fetch & queue 
# requests
#
# throws fetch_queue_failed if the HTTP Request did not return a 200 code
# parameter max int the maximum amount of requests to fetch
#
%include "../graphql/index.liq"

def fetch_queue(~max=1) =
    def log(x) = log(label="fetch_queue", x) end

    graphql_request(
        query="query fetch_queue($limit: Int) {
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
        }",
        variables={
            limit = max
        }
    )
end

fetch_queue(max=1)