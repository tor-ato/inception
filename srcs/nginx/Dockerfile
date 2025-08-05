FROM alpine:3.21.4

# Install nginx
RUN apk update && apk upgrade && apk add nginx openssl

# Copy entrypoint.sh
COPY ./entrypoint.sh /usr/local/bin/

# Expose ports
EXPOSE 80 443

# Run entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
