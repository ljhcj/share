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

#低版本系统需要插入认证码
rpm --import http://centos.ustc.edu.cn/centos/RPM-GPG-KEY-CentOS-5

#关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#安装基础环境
yum -y install php-mysql  mysql-devel gcc gcc-c++ libgnomeui-devel bison
yum -y install ncurses-devel perl-Time-HiRes httpd mysql-server php libdbi-dbd-mysql perl-libwww-perl

#启动/关闭服务
service httpd start
service mysqld start
service iptables stop
chkconfig httpd on
chkconfig mysqld on
chkconfig iptables off

#用wget下载文件到/usr/local/src/
wget -P /usr/local/src/ http://112.33.20.58:8070/dahdi-linux-complete-2.5.0.2+2.5.0.2.tar.gz
wget -P /usr/local/src/ http://112.33.20.58:8070/libpri-1.4.12.tar.gz
wget -P /usr/local/src/ http://112.33.20.58:8070/asterisk-1.4.43.tar.gz
wget -P /usr/local/src/ http://112.33.20.58:8070/asterisk-addons-1.4.13.tar.gz
wget -P /usr/local/src/ http://112.33.20.58:8070/freeiris2-current.tar.gz

#开始安装部署
cd /usr/local/src/
tar zxvf dahdi-linux-complete-2.5.0.2+2.5.0.2.tar.gz
cd dahdi-linux-complete-2.5.0.2+2.5.0.2
make install
make config
/etc/init.d/dahdi start
/etc/init.d/dahdi stop
cd ..
tar zxvf libpri-1.4.12.tar.gz
cd libpri-1.4.12
make
make install
cd ..
tar zxvf asterisk-1.4.43.tar.gz
cd asterisk-1.4.43
./configure
make
make install
make samples
make config
cd ..
tar zxvf asterisk-addons-1.4.13.tar.gz
cd asterisk-addons-1.4.13
./configure
make cdr
cp cdr/cdr_addon_mysql.so /usr/lib/asterisk/modules/
cd ..
tar zxvf freeiris2-current.tar.gz
cd freeiris2-*

chmod +x install.pl
./install.pl --install

#重启系统并加载
init 6
