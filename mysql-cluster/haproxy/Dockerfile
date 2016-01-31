FROM haproxy

RUN apt-get update -qq && apt-get upgrade -qq -y \
    && mkdir -p /usr/local/etc/haproxy

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

EXPOSE 3306

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
