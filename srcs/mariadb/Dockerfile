FROM alpine:3.18.5

# Install mariadb
RUN apk update && apk upgrade && \
    apk add --no-cache mariadb mariadb-client

# Setup directories
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    chmod 1777 /run/mysqld

# Copy entrypoint
COPY ./entrypoint.sh /usr/local/bin/

# Volumes
VOLUME ["/var/lib/mysql"]

# Expose ports
EXPOSE 3306

# Run entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
