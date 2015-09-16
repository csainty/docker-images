FROM alpine:3.2

ENV JAVA_HOME=/usr/lib/jvm/default-jvm JAVA_VERSION=8 JAVA_UPDATE=60 JAVA_BUILD=27

RUN apk add --update libgcc ca-certificates wget && \
  cd /tmp && \
  wget -nv "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
       "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
  apk add --allow-untrusted /tmp/glibc-2.21-r2.apk /tmp/glibc-bin-2.21-r2.apk && \
  /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
  wget -nv --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
  tar xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
  mkdir -p /usr/lib/jvm && \
  mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" /usr/lib/jvm/java-${JAVA_VERSION}-oracle && \
  ln -s "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" $JAVA_HOME && \
  ln -s /usr/lib/jvm/default-jvm/bin/java /usr/bin/java && \
  ln -s /usr/lib/jvm/default-jvm/bin/javac /usr/bin/javac && \
  ln -s /usr/lib/jvm/default-jvm/bin/jar /usr/bin/jar && \
  apk del wget ca-certificates && \
  rm -rf /var/cache/apk/* /tmp/* && \
  cd /usr/lib/jvm && \
  rm -rf default-jvm/*src.zip \
         default-jvm/lib/missioncontrol \
         default-jvm/lib/visualvm \
         default-jvm/lib/*javafx* \
         default-jvm/jre/lib/plugin.jar \
         default-jvm/jre/lib/ext/jfxrt.jar \
         default-jvm/jre/bin/javaws \
         default-jvm/jre/lib/javaws.jar \
         default-jvm/jre/lib/desktop \
         default-jvm/jre/plugin \
         default-jvm/jre/lib/deploy* \
         default-jvm/jre/lib/*javafx* \
         default-jvm/jre/lib/*jfx* \
         default-jvm/jre/lib/amd64/libdecora_sse.so \
         default-jvm/jre/lib/amd64/libprism_*.so \
         default-jvm/jre/lib/amd64/libfxplugins.so \
         default-jvm/jre/lib/amd64/libglass.so \
         default-jvm/jre/lib/amd64/libgstreamer-lite.so \
         default-jvm/jre/lib/amd64/libjavafx*.so \
         default-jvm/jre/lib/amd64/libjfx*.so
