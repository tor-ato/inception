#!/bin/sh
set -ex

WP_CLI="su-exec www-data php -d memory_limit=512M /usr/local/bin/wp"

copy_wordpress_to_volume() {
    if [ -f "$WP_DIR/wp-includes/version.php" ]; then
        return
    fi
    cp -a /usr/src/wordpress/. "$WP_DIR/"
    chown -R www-data:www-data "$WP_DIR"
    chmod -R 755 "$WP_DIR"
}

setup_wordpress() {
    if $WP_CLI core is-installed --path="$WP_DIR"; then
        return
    fi

    $WP_CLI config create --path="$WP_DIR" \
        --dbhost="${WP_DB_HOST}" \
        --dbname="${WP_DB_NAME}" \
        --dbuser="${WP_DB_USER}" \
        --dbpass="${WP_DB_PASSWORD}" \
        --force

    $WP_CLI core install --path="$WP_DIR" \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"
}

create_editor_user() {
    local user="${WP_EDITOR_USER}"
    local email="${WP_EDITOR_EMAIL}"

    if $WP_CLI user list --path="$WP_DIR" --field=user_login | grep -q "^$user$"; then
        return
    fi

    $WP_CLI user create --path="$WP_DIR" \
        "$user" \
        "$email" \
        --role=editor \
        --user_pass="${WP_EDITOR_PASSWORD}"
}

main() {
    copy_wordpress_to_volume
    setup_wordpress
    create_editor_user
    exec php-fpm82 -F
}

main
