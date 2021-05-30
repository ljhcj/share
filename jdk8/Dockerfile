FROM alpine:3.13.3

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
ENV JAVA_HOME=/usr/local/jdk
ENV JAVA_DOWNLOAD=

ADD glibc-2.33-r0.apk /tmp
ADD glibc-bin-2.33-r0.apk /tmp
ADD glibc-i18n-2.33-r0.apk /tmp
ADD locale.md /tmp
ADD ttf-dejavu.tar.gz /tmp
/usr/share/fonts/

RUN cd /tmp \
    && apk add --update --no-cache --virtual=build-dependencies curl wget tzdata ttf-dejavu bash ca-certificates tar \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && apk add --no-cache glibc-2.33-r0.apk glibc-bin-2.33-r0.apk glibc-i18n-2.33-r0.apk \
    && tar -xvf ttf-dejavu.tar.gz -C /usr/share/fonts/ \
    && curl -jfksSLH "Cookie: oraclelicense=accept-securebackup-cookie" \
    "${JAVA_DOWNLOAD:-$(curl -s https://lv.binarybabel.org/catalog-api/java/jdk8.txt?p=downloads.tgz)}" \
    | tar -xzf - -C /usr/local/ \
    && ln -s /usr/local/jdk1.*.0_* /usr/local/jdk \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
    && echo "Asia/Shanghai" > /etc/timezone \
    && cat locale.md | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8 \
    && rm -rf ${JAVA_HOME}/*src.zip \
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
           /tmp/*

ENV JAVA_HOME /usr/local/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

WORKDIR /
