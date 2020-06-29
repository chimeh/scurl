FROM alpine:3.12
COPY _bin/scurl /usr/local/bin/scurl
RUN chmod +x /usr/local/bin/scurl
