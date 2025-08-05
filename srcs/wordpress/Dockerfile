FROM alpine:3.21.4

# Install packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    curl fcgi su-exec \
    php82 php82-fpm php82-mysqli php82-json php82-openssl php82-curl \
    php82-zlib php82-xml php82-phar php82-intl php82-dom php82-xmlreader \
    php82-ctype php82-mbstring php82-gd php82-session

# Create symlink
RUN ln -s /usr/bin/php82 /usr/bin/php

# Ensure www-data user exists
# 82 is the standard uid/gid for "www-data" in Alpine
RUN addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data ; true

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Setup directories
ENV WP_DIR=/var/www/html
RUN mkdir -p $WP_DIR && \
    chown -R www-data:www-data $WP_DIR && \
    chmod 755 $WP_DIR

# Set working directory
WORKDIR $WP_DIR

# Download wordpress
# memory limit に引っかかって失敗するので、このコマンドだけ上限を上げる
RUN su-exec www-data \
    php -d memory_limit=512M /usr/local/bin/wp core download --path=$WP_DIR

# Copy entrypoint.sh
COPY ./entrypoint.sh /usr/local/bin/

# Volume
VOLUME $WP_DIR

# Expose ports
EXPOSE 9000

# Run entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
