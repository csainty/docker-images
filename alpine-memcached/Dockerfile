FROM alpine:3.2

RUN addgroup memcache && adduser -s /bin/bash -D -G memcache memcache

RUN apk upgrade --update && \
	apk --update add memcached && \
	rm /var/cache/apk/*

USER memcache
EXPOSE 11211
CMD ["memcached"]