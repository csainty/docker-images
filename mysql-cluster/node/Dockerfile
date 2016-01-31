FROM centos:7

# Added first for consistent id
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Install percona
RUN yum install -q -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm \
    && yum upgrade -q -y \
    && yum install -q -y socat which xinetd \
    && yum install -q -y Percona-XtraDB-Cluster-56 \
    && echo "mysqlchk        9200/tcp                # mysqlchk" >> /etc/services

# Delete the default database it creates so we can create our own
RUN rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql \
    && mkdir -p /var/backups/mysql \
    && chown -R mysql:mysql /var/lib/mysql \
    && chown -R mysql:mysql /var/backups/mysql

EXPOSE 3306 4444 4567 4568

VOLUME ["/var/lib/mysql", "/var/log/mysql", "/var/backups/mysql"]

COPY docker-entrypoint.sh /entrypoint.sh
COPY my.cnf /etc/my.cnf

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld"]
