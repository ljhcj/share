FROM registry.cn-qingdao.aliyuncs.com/ljh_base/jdk:1.8.291

RUN wget -qP /usr/local/ https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz \
    && cd /usr/local/ && tar -xf apache-tomcat-9.0.50.tar.gz \
    && rm -rf /usr/local/apache-tomcat-9.0.50/webapps/*

EXPOSE 8080

CMD ["/usr/local/apache-tomcat-9.0.50/bin/catalina.sh","run"]
