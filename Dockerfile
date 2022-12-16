FROM savonet/liquidsoap:v2.1.3

WORKDIR /app

COPY ./ /app

CMD ["/app/main.liq"]

