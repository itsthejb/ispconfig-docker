#!/usr/bin/env bats

load helpers

setup() {
  installDependencies &> /dev/null
  apk add mariadb-client curl
  waitForUp
}

@test "services have been reconfigured to MYSQL_HOST" {
  docker exec ispconfig grep "^\$conf\['db_host'\] = '0.0.0.0';$" /usr/local/ispconfig/interface/lib/config.inc.php
  docker exec ispconfig grep "^\$dbserver='0.0.0.0';$" /etc/phpmyadmin/config-db.php
  docker exec ispconfig grep "^\$config\['db_dsnw'\] = 'mysql://roundcube:secretpassword@0.0.0.0/roundcube';$" /opt/roundcube/config/config.inc.php
}

@test "ispconfig database connection" {
  # The logo is stored in the database
  curl -Lk "https://ispconfig:8080" | grep -E '<img src="data:image/png;base64,.*>'
}

@test "roundcube database connection" {
  curl -Lk "https://ispconfig:8080/webmail/" | grep -v 'DATABASE ERROR: CONNECTION FAILED!'
}

# How to test phpMyAdmin?