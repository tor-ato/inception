#!/bin/sh
set -ex

init_db() {
	if [ -d "/var/lib/mysql/mysql" ]; then
		return
	fi
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
}

run_temp_mariadb() {
	if pgrep mariadbd >/dev/null; then
	    	return
	fi
	mariadbd --user=mysql --datadir=/var/lib/mysql &
	sleep 3
}

kill_temp_mariadb() {
	if ! pgrep mariadbd >/dev/null; then
	    	return
	fi
	killall mariadbd
	while pgrep mariadbd >/dev/null; do
		sleep 1
	done
}

create_user() {
	if  mariadb -u root -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$1');" | grep -q 1; then
		return
	fi
	mariadb -u root <<-EOSQL
		CREATE USER '$1'@'%' IDENTIFIED BY '$2';
	EOSQL

	mariadb -u root <<-EOSQL
		GRANT ALL PRIVILEGES ON *.* TO '$1'@'%' WITH GRANT OPTION;
		FLUSH PRIVILEGES;
	EOSQL
}

create_database() {
	if  mariadb -u root -sse "SHOW DATABASES LIKE '$1';" | grep -q "$1"; then
		return
	fi
	mariadb -u root <<-EOSQL
		CREATE DATABASE IF NOT EXISTS \`$1\`;
	EOSQL
}

main() {
	init_db
	run_temp_mariadb
	create_database "$MARIADB_DATABASE"
	create_user "$MARIADB_USER" "$MARIADB_PASSWORD"
	kill_temp_mariadb

	exec mariadbd-safe --user=mysql --datadir=/var/lib/mysql
}

main
