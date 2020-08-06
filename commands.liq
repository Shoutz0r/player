# Add a skip function to a source
# when it does not have one
# by default
def add_skip_command(s) =
    # A command to skip
    def skip(_) =
        source.skip(s)
        "Done!"
    end
    # Register the command:
    server.register(namespace="#{source.id(s)}",
                     usage="skip",
                     description="Skip the current song.",
                     "skip",skip)
end

# Add a skip function to a source
# when it does not have one
# by default
def add_to_queue(source,~action="override", ~protocol, ~data, ~headers, uri) =
    log("adding track to queue: '#{track}'")

    server.execute("playnow.push #{track}")

    http_response(
        protocol=protocol,
        code=200,
        headers=[("Content-Type","application/json; charset=utf-8")],
        data='{"status":"success", "track": "#{track}", "action": "#{action}"}'
    )
end