#!/bin/bash
#修改yum源路径地址
tee /etc/yum.repos.d/CentOS-Base.repo <<-'EOF'
[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
baseurl=http://vault.centos.org/5.6/os/$basearch/
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
gpgkey=file://vault.centos.org/5.6/os/i386/RPM-GPG-KEY-CentOS-5
EOF

#安装基础环境
yum -y install php-mysql  mysql-devel gcc gcc-c++ libgnomeui-devel bison
yum -y install ncurses-devel perl-Time-HiRes httpd mysql-server php libdbi-dbd-mysql perl-libwww-perl

#启动/关闭服务
for SERVICES in httpd mysqld; do
    service $SERVICES restart
    chkconfig $SERVICES on
done

service iptables stop
chkconfig iptables off
