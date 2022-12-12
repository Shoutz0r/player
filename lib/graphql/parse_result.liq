# Example usage:
# Query the GraphQL server for user data
# success, data = parse_result(<output from make_request>)
def parse_graphql_result(result) =
  # Parse the JSON response
  let json.parse response = result

  # Check if errors is null
  if null.defined(response.errors) then
    # If there are errors, return a list of error messages
    error_messages = ref([])

    def add_error(e)
      error_messages := list.add(null.get(e.message), !error_messages)
    end

    # Iterate over all errors, and add the message to the list
    list.iter(
        fun(e) -> add_error(e),
        null.get(response.errors)
    )

    # Return the list of errors
    (false, !error_messages)
  else
    # If there are no errors, return the data from the response
    (true, null.get(response.data))
  end
end