#!/bin/bash
set -eo pipefail

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
    set -- mysqld "$@"
fi

if [ "$1" = 'mysqld' ]; then
    # Get config
    DATADIR="/var/lib/mysql"

    if [ -z "$CLUSTER_NODE_NAME" -o -z "$CLUSTER_NAME" -o -z "$BACKUP_USER" -o -z "$BACKUP_PASSWORD" -o -z "$CHECK_PASSWORD" ]; then
        echo >&2 'error: You need to specify CLUSTER_NAME, CLUSTER_NODE_NAME, BACKUP_USER, BACKUP_PASSWORD, CHECK_PASSWORD'
        exit 1
    fi

    sed -i "s/wsrep_cluster_address.*/wsrep_cluster_address=gcomm:\/\/${CLUSTER_ADDR}/g" /etc/my.cnf
    sed -i "s/wsrep_cluster_name.*/wsrep_cluster_name=${CLUSTER_NAME}/g" /etc/my.cnf
    sed -i "s/wsrep_node_name.*/wsrep_node_name=${CLUSTER_NODE_NAME}/g" /etc/my.cnf
    sed -i "s/wsrep_sst_auth.*/wsrep_sst_auth=\"${BACKUP_USER}:${BACKUP_PASSWORD}\"/g" /etc/my.cnf
    sed -i "s/clustercheckpassword!/${CHECK_PASSWORD}/g" /usr/bin/clustercheck

    if [ ! -z "$INNODB_BUFFER_POOL_SIZE" ]; then
        sed -i "s/innodb_buffer_pool_size.*/innodb_buffer_pool_size=${INNODB_BUFFER_POOL_SIZE}/g" /etc/my.cnf
    fi

    if [ ! -z "$INNODB_LOG_FILE_SIZE" ]; then
        sed -i "s/innodb_log_file_size.*/innodb_log_file_size=${INNODB_LOG_FILE_SIZE}/g" /etc/my.cnf
    fi

    if [ ! -z "$MAX_CONNECTIONS" ]; then
        sed -i "s/max_connections.*/max_connections=${MAX_CONNECTIONS}/g" /etc/my.cnf
    fi

    if [ ! -d "$DATADIR/mysql" -a -z "$CLUSTER_ADDR" ]; then
        if [ -z "$MYSQL_ROOT_PASSWORD" -o -z "$BACKUP_USER" -o -z "$BACKUP_PASSWORD" -o -z "$CHECK_PASSWORD" ]; then
            echo >&2 'error: You need to specify MYSQL_ROOT_PASSWORD, BACKUP_USER, BACKUP_PASSWORD, CHECK_PASSWORD'
            exit 1
        fi

        echo 'Initializing database'
        mysql_install_db --user=mysql --datadir="$DATADIR" --rpm
        echo 'Database initialized'

        "$@" --skip-networking &
        pid="$!"

        mysql=( mysql -uroot )

        for i in {30..0}; do
            if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
                break
            fi
            echo 'MySQL init process in progress...'
            sleep 1
        done
        if [ "$i" = 0 ]; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
            # sed is for https://bugs.mysql.com/bug.php?id=20545
            mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql
        fi

        "${mysql[@]}" <<-EOSQL
            -- What's done in this file shouldn't be replicated
            --  or products like mysql-fabric won't work
            SET @@SESSION.SQL_LOG_BIN=0;

            DELETE FROM mysql.user ;
            FLUSH PRIVILEGES ;
            CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
            GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
            DROP DATABASE IF EXISTS test ;
            CREATE USER '${BACKUP_USER}'@'%' IDENTIFIED BY '${BACKUP_PASSWORD}' ;
            GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '${BACKUP_USER}'@'%' ;
            GRANT PROCESS ON *.* TO 'clustercheckuser'@'%' IDENTIFIED BY '${CHECK_PASSWORD}';
            FLUSH PRIVILEGES ;
EOSQL

        mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )

        if [ "$MYSQL_DATABASE" ]; then
            echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
            mysql+=( "$MYSQL_DATABASE" )
        fi

        if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
            echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"
            echo "GRANT ALL ON *.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
            echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
        fi

        if ! kill -s TERM "$pid" || ! wait "$pid"; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        echo
        echo 'MySQL init process done. Ready for start up.'
        echo
    fi

    chown -R mysql:mysql "$DATADIR"
    /usr/sbin/xinetd
fi

exec "$@"
