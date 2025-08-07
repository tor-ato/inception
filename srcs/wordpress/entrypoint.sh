#!/bin/sh
set -ex

setup_wordpress() {
	if su-exec www-data wp core is-installed --path="$WP_DIR"; then
		echo "wordpress already installed"
		return
	fi

	echo "Setting up wordpress..."
	su-exec www-data php -d memory_limit=512M /usr/local/bin/wp config create --path="$WP_DIR" \
		--dbhost="${WP_DB_HOST:-mysql}" \
		--dbname="${WP_DB_NAME:-wordpress}" \
		--dbuser="${WP_DB_USER:-wordpress}" \
		--dbpass="${WP_DB_PASSWORD:?}" \
		--force
	su-exec www-data php -d memory_limit=512M /usr/local/bin/wp core install --path="$WP_DIR" \
		--url="${WP_URL:?}" \
		--title="${WP_TITLE:-"Wordpress"}" \
		--admin_user="${WP_ADMIN_USER:-"admin"}" \
		--admin_password="${WP_ADMIN_PASSWORD:?}" \
		--admin_email="${WP_ADMIN_EMAIL:-"admin@example.com"}"
	echo "wordpress setup successfully"
}


create_editor_user() {
    user="${WP_EDITOR_USER:-"editor"}"
    email="${WP_EDITOR_EMAIL:-"editor@example.com"}"
    # ユーザー名がすでに存在していれば作らない
    if su-exec www-data php -d memory_limit=512M /usr/local/bin/wp user list --path="$WP_DIR" --field=user_login | grep -q "^$user$"; then
        echo "editor user already exists"
        return
    fi

    echo "Creating editor user..."
    su-exec www-data php -d memory_limit=512M /usr/local/bin/wp user create --path="$WP_DIR" \
        "$user" \
        "$email" \
        --role=editor \
        --user_pass="${WP_EDITOR_PASSWORD:?}"
    echo "editor user created successfully"
}


# 最初にディレクトリの所有権を確実に設定する
fix_permissions() {
    echo "ディレクトリのパーミッションを修正しています..."
    # rootユーザーとして実行（エントリポイントはrootで実行される）
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
}

copy_wordpress_to_volume() {
    # まず権限を修正してから処理を行う
    fix_permissions

    if [ ! -f "/var/www/html/wp-includes/version.php" ]; then
        echo "WordPressコアファイルが見つかりません。usr/srcからコピーします..."
        # wp-cliの代わりに手動でコピー
        cp -a /usr/src/wordpress/. /var/www/html/
        chown -R www-data:www-data /var/www/html
    else
        echo "WordPressコアファイルは既に存在します"
    fi
}

main() {
	fix_permissions
	copy_wordpress_to_volume
	setup_wordpress
	if [ -n "$WP_EDITOR_PASSWORD" ]; then
		create_editor_user
	fi
	fix_permissions

	# Start php-fpm82
	exec php-fpm82 -F
}

main
