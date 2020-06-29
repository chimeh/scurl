FROM alpine:3.12
COPY _bin/curl /usr/local/bin/scurl
RUN chmod +x /usr/local/bin/scurl
