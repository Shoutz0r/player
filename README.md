# Shoutz0r-player
The Shoutz0r media player.\
This player will communicate with the Shoutz0r backend to fetch & play requests

## Installation
- Copy `.env.example` to `.env` and edit the variables as needed
    - Keep in mind the icecast server listens internally on port 8000, this is also where the player connects to.\
      To the public port 9000 is exposed instead (because the backend API already runs on port 8000).\
      Make sure to leave `ICECAST_SOURCE_PORT` set to `8000` when you're using the icecast server from this docker compose file
- Run `docker compose up`, this will start the Shoutz0r Player

## Credits
fallback video - <a href="https://pixabay.com/users/EnchantedStudios-722609/">Simon Brough</a>
