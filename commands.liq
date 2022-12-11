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