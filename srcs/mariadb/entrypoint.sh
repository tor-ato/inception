#!/bin/sh
set -ex

init_db() {
	if [ ! -d "/var/lib/mysql/mysql" ]; then
		echo "Initializing database..."
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
		echo "Database initialized successfully"
	else
		echo "Database already initialized"
	fi
}

run_temp_mariadb() {
	if ! pgrep mariadbd >/dev/null; then
		mariadbd --user=mysql --datadir=/var/lib/mysql &
		sleep 3
	fi
}

kill_temp_mariadb() {
	if pgrep mariadbd >/dev/null; then
		killall mariadbd
		while pgrep mariadbd >/dev/null; do
			sleep 1
		done
	fi
}

create_user() {
	if [ $# -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
		echo "Failed to create user: invalid arguments"
		exit 1
	fi
	if ! mariadb -u root -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$1');" | grep -q 1; then
		echo "Creating user '$1'..."
		mariadb -u root <<-EOSQL
			CREATE USER '$1'@'%' IDENTIFIED BY '$2';
			CREATE USER '$1'@'localhost' IDENTIFIED BY '$2';
			GRANT ALL PRIVILEGES ON *.* TO '$1'@'%' WITH GRANT OPTION;
			GRANT ALL PRIVILEGES ON *.* TO '$1'@'localhost' WITH GRANT OPTION;
			FLUSH PRIVILEGES;
		EOSQL
		echo "User '$1' created successfully"
	else
		echo "User '$1' already exists"
	fi
}

create_database() {
	if [ $# -ne 1 ] || [ -z "$1" ]; then
		echo "Failed to create database: invalid arguments"
		exit 1
	fi
	if ! mariadb -u root -sse "SHOW DATABASES LIKE '$1';" | grep -q "$1"; then
		echo "Creating database '$1'..."
		mariadb -u root <<-EOSQL
			CREATE DATABASE IF NOT EXISTS \`$1\`;
		EOSQL
		echo "Database '$1' created successfully"
	else
		echo "Database '$1' already exists"
	fi
}

main() {
	init_db
	run_temp_mariadb
	if [ -n "$MARIADB_DATABASE" ]; then
		create_database "$MARIADB_DATABASE"
	fi
	if [ -n "$MARIADB_USER" ] && [ -n "$MARIADB_PASSWORD" ]; then
		create_user "$MARIADB_USER" "$MARIADB_PASSWORD"
	fi
	kill_temp_mariadb

	# Start mariadb
	exec mariadbd-safe --user=mysql --datadir=/var/lib/mysql
}

main
