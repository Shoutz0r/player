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

#
# use ignore because of warnings
#
ignore(output_format)