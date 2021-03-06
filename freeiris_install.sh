#!/bin/bash

#以下说明都以Centos 5.6为例
#下面操作在centos 5.6安装成功后操作
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

#关闭selinux并添加github解析
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo '199.232.68.133 raw.githubusercontent.com' >>/etc/hosts

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

#用wget下载文件到/usr/local/src/并解压
wget -P /usr/local/src/ https://github.com/ljhcj/share/raw/master/dahdi-linux-complete-2.5.0.2%2B2.5.0.2.tar.gz
wget -P /usr/local/src/ https://github.com/ljhcj/share/raw/master/libpri-1.4.12.tar.gz
wget -P /usr/local/src/ https://github.com/ljhcj/share/raw/master/asterisk-1.4.43.tar.gz
wget -P /usr/local/src/ https://github.com/ljhcj/share/raw/master/asterisk-addons-1.4.13.tar.gz
wget -P /usr/local/src/ https://github.com/ljhcj/share/raw/master/freeiris2-current.tar.gz

#开始安装部署
######################################################################################
#安装dahdi驱动
######################################################################################
cd /usr/local/src/
tar zxvf dahdi-linux-complete-2.5.0.2+2.5.0.2.tar.gz
cd dahdi-linux-complete-2.5.0.2+2.5.0.2
make install
make config
/etc/init.d/dahdi start
/etc/init.d/dahdi stop
cd ..
######################################################################################
#安装libpri
######################################################################################
tar zxvf libpri-1.4.12.tar.gz
cd libpri-1.4.12
make
make install
cd ..
######################################################################################
#安装asterisk
######################################################################################
tar zxvf asterisk-1.4.43.tar.gz
cd asterisk-1.4.43
./configure
make
make install
make samples
make config
cd ..
######################################################################################
#安装asterisk-addons
######################################################################################
tar zxvf asterisk-addons-1.4.13.tar.gz
cd asterisk-addons-1.4.13
./configure
make cdr
cp cdr/cdr_addon_mysql.so /usr/lib/asterisk/modules/
cd ..
######################################################################################
#安装freeiris2
######################################################################################
tar zxvf freeiris2-current.tar.gz
cd freeiris2-*

chmod +x install.pl
./install.pl --install
######################################################################################
freeiris添加用户及配置修改
######################################################################################
sed -i 's/deny=0.0.0.0\/0.0.0.0/;deny=0.0.0.0\/0.0.0.0/' /etc/asterisk/manager.conf
sed -i 's/permit=127.0.0.1\/255.255.255.0/;permit=127.0.0.1\/255.255.255.0/' /etc/asterisk/manager.conf

cat >> /etc/asterisk/manager.conf <<EOF
[cron]
secret = 1234
read = system,call,log,verbose,command,agent,user
write = system,call,log,verbose,command,agent,user
EOF
######################################################################################
替换路由文件
######################################################################################
rm -rf /freeiris2/agimod/router.dynamic
wget -P /freeiris2/agimod/ https://raw.githubusercontent.com/ljhcj/share/master/router.dynamic
chown 500:500 /freeiris2/agimod/router.dynamic
chmod 775 /freeiris2/agimod/router.dynamic

#重启系统并加载
init 6
