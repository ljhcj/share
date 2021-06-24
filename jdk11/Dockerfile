FROM alpine:3.13.3

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
ENV JAVA_HOME=/usr/local/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

RUN mkdir -p /usr/local/src/ && cd /usr/local/src/ && \
    apk add --update --no-cache --virtual=build-dependencies wget tzdata ttf-dejavu bash ca-certificates && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-2.33-r0.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-bin-2.33-r0.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-i18n-2.33-r0.apk && \
    apk add --no-cache glibc-2.33-r0.apk glibc-bin-2.33-r0.apk glibc-i18n-2.33-r0.apk && \
    mv /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /usr/glibc-compat/lib/ld-linux-x86-64.so && \
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \ 
    https://download.oracle.com/otn-pub/java/jdk/11.0.11%2B9/ab2da78f32ed489abb3ff52fd0a02b1c/jdk-11.0.11_linux-x64_bin.tar.gz && \
    tar -xf jdk-11.0.11_linux-x64_bin.tar.gz -C /usr/local/ && \
    ln -s /usr/local/jdk-11.*.* /usr/local/jdk && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \ 
    echo "Asia/Shanghai" > /etc/timezone && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
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
           ${JAVA_HOME}/jre/bin/jjs" \
           ${JAVA_HOME}/jre/bin/keytool" \
           ${JAVA_HOME}/jre/bin/orbd" \
           ${JAVA_HOME}/jre/bin/pack200" \
           ${JAVA_HOME}/jre/bin/policytool" \
           ${JAVA_HOME}/jre/bin/rmid" \
           ${JAVA_HOME}/jre/bin/rmiregistry" \
           ${JAVA_HOME}/jre/bin/servertool" \
           ${JAVA_HOME}/jre/bin/tnameserv" \
           ${JAVA_HOME}/jre/bin/unpack200" \
           ${JAVA_HOME}/jre/bin/javaws" \
           ${JAVA_HOME}/jre/lib/plugin.jar" \
           ${JAVA_HOME}/jre/lib/ext/jfxrt.jar" \
           ${JAVA_HOME}/jre/lib/javaws.jar" \
           ${JAVA_HOME}/jre/lib/desktop" \
           ${JAVA_HOME}/jre/lib/ext/nashorn.jar" \
           ${JAVA_HOME}/jre/lib/jfr.jar" \
           ${JAVA_HOME}/jre/lib/jfr" \
           ${JAVA_HOME}/jre/lib/oblique-fonts" \
           ${JAVA_HOME}/jre/plugin" \
           ${JAVA_HOME}/jre/lib/"deploy* \
           ${JAVA_HOME}/jre/lib/"*javafx* \
           ${JAVA_HOME}/jre/lib/"*jfx* \
           ${JAVA_HOME}/jre/lib/amd64/libdecora_sse.so" \
           ${JAVA_HOME}/jre/lib/amd64/"libprism_*.so \
           ${JAVA_HOME}/jre/lib/amd64/libfxplugins.so" \
           ${JAVA_HOME}/jre/lib/amd64/libglass.so" \
           ${JAVA_HOME}/jre/lib/amd64/libgstreamer-lite.so" \
           ${JAVA_HOME}/jre/lib/amd64/"libjavafx*.so \
           ${JAVA_HOME}/jre/lib/amd64/"libjfx*.so \
           /usr/local/src/*
