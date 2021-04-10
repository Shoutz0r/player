FROM savonet/liquidsoap:v2.0.0-alpha1

USER root

# Create the opam environment and install required packages
RUN opam init --disable-sandboxing --bare && \
	opam switch create 4.08.0

RUN opam depext ao bjack cry fdkaac ffmpeg frei0r gavl gstreamer lo magic opus portaudio shine ssl taglib xmlplaylist duppy mm && \
	opam install ao bjack cry fdkaac ffmpeg frei0r gavl gstreamer lo magic opus portaudio shine ssl taglib xmlplaylist

RUN sudo apt install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev gstreamer1.0-plugins-good gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libx264-dev x264

RUN eval $(opam config env)

USER liquidsoap

CMD ["liquidsoap", "/home/liquidsoap/app/main.liq"]