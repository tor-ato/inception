FROM alpine:3.21.4

# Install packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    curl su-exec \
    php82 \
    php82-fpm \
    php82-mysqli php82-json php82-openssl php82-curl \
    php82-phar php82-mbstring php82-session

    #php82 PHP 本体
    #php82-fpm Nginx と通信するデーモンFastCGI Process Manager
    #php82-phar アーカイブ回答実行用。ないとwpコマンドが動かない
    #php82-mbstring 日本語対応

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

# WordPressを手動でダウンロードして展開
RUN mkdir -p /usr/src/wordpress && \
    curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /usr/src/ && \
    rm /tmp/wordpress.tar.gz && \
    chown -R www-data:www-data /usr/src/wordpress

# ボリュームマウント用のディレクトリを準備
RUN mkdir -p $WP_DIR && \
    chown -R www-data:www-data $WP_DIR && \
    chmod 755 $WP_DIR

# Set working directory
WORKDIR $WP_DIR

# Copy entrypoint.sh
COPY ./entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Volume
VOLUME $WP_DIR

# Expose ports
EXPOSE 9000

# Run entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
