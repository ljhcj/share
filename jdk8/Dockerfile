FROM alpine:3.13.3

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
ENV JAVA_HOME=/usr/local/jdk

RUN mkdir -p /usr/local/src/ && cd /usr/local/src/ && \
    apk add --update --no-cache --virtual=build-dependencies wget tzdata ttf-dejavu fontconfig bash ca-certificates tar && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-2.33-r0.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-bin-2.33-r0.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-i18n-2.33-r0.apk && \
    apk add --no-cache glibc-2.33-r0.apk glibc-bin-2.33-r0.apk glibc-i18n-2.33-r0.apk && \
    mv /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /usr/glibc-compat/lib/ld-linux-x86-64.so && \
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \ 
    http://download.oracle.com/otn-pub/java/jdk/8u291-b10/d7fc238d0cbf4b0dac67be84580cfb4b/jdk-8u291-linux-x64.tar.gz && \
    tar -xf jdk-8u291-linux-x64.tar.gz -C /usr/local/ && \
    ln -s /usr/local/jdk1.*.0_* /usr/local/jdk && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \ 
    echo "Asia/Shanghai" > /etc/timezone && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    rm -rf ${JAVA_HOME}/*src.zip \
           ${JAVA_HOME}/THIRDPARTYLICENSEREADME* \
           ${JAVA_HOME}/lib/missioncontrol \
           ${JAVA_HOME}/lib/visualvm \
           ${JAVA_HOME}/lib/*javafx* \
           ${JAVA_HOME}/lib/plugin.jar \
           ${JAVA_HOME}/lib/ext/jfxrt.jar \
           ${JAVA_HOME}/bin/javaws \
           ${JAVA_HOME}/lib/javaws.jar \
           ${JAVA_HOME}/lib/desktop \
           ${JAVA_HOME}/plugin \
           ${JAVA_HOME}/lib/deploy* \
           ${JAVA_HOME}/lib/*javafx* \
           ${JAVA_HOME}/lib/*jfx* \
           ${JAVA_HOME}/lib/amd64/libdecora_sse.so \
           ${JAVA_HOME}/lib/amd64/libprism_*.so \
           ${JAVA_HOME}/lib/amd64/libfxplugins.so \
           ${JAVA_HOME}/lib/amd64/libglass.so \
           ${JAVA_HOME}/lib/amd64/libgstreamer-lite.so \
           ${JAVA_HOME}/lib/amd64/libjavafx*.so \
           ${JAVA_HOME}/lib/amd64/libjfx*.so \
           /var/cache/apk/* \
           /usr/local/src/* 

ENV JAVA_HOME /usr/local/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

WORKDIR /
