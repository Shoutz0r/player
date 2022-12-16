###
# Shoutz0r (player) settings
###

# The url where the API can be reached; ie: "http://api:8000/graphql"
api_graphql_url = getenv("API_GRAPHQL_URL")

# The accesstoken to authenticate ourselves with against the API
api_accesstoken = getenv("API_ACCESSTOKEN")

# The directory where media files are located. Should NOT end with a '/'
media_storage_path = getenv("MEDIA_STORAGE_PATH")

###
# Icecast settings
###

# Output Icecast server config values
icecast_host = getenv("ICECAST_SOURCE_SERVER")
icecast_port = int_of_string(getenv("ICECAST_SOURCE_PORT"))
icecast_mount = getenv("ICECAST_SOURCE_MOUNT")
icecast_password = getenv("ICECAST_SOURCE_PASSWORD")

###
# Encoding settings
###

# The output encoding format
output_format = %mp3(
					bitrate=320
				)

#
# use ignore because of warnings
#
ignore(api_graphql_url)
ignore(media_storage_path)
ignore(icecast_host)
ignore(icecast_port)
ignore(icecast_mount)
ignore(icecast_password)
ignore(output_format)