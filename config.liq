# The output encoding format
output_format = %ffmpeg(
    format="webm", 
    %audio(
        codec="aac",
        b="128k",
    ),
    %video(
        codec="libx264",
        b="5M"
    )
)

# The output encoding format
# Debugging override.
output_format = %ffmpeg(
    format="mp3", 
    %audio(
        codec="aac",
        b="128k",
    )
)

#
# use ignore because of warnings
#
ignore(output_format)