#!/bin/bash
##set color##
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }
##set color##
#ENV#
dir=`pwd`
nginx_version=1.18.0
#判断一下当前用户
if [ "`whoami`" != "root" ];then
    echoRed "注意：当前系统用户非root用户，将无法执行安装等事宜！" && exit 1
fi
#---------------------------------------------------------------------------------------------------------------------------------------------
#               三级方法
#---------------------------------------------------------------------------------------------------------------------------------------------
#install
nginx(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/nginx ] && echoRed "检测到/usr/local下已安装ngixn，故而退出!" && rm -rf $dir/nginx-* && exit 1
    [ ! -f $dir/nginx-${nginx_version}.tar.gz ] && wget -nc http://nginx.org/download/nginx-${nginx_version}.tar.gz
    yum install gcc gcc-c++ pcre pcre pcre-devel zlib zlib-devel openssl openssl-devel -y
    tar -xvzf nginx-${nginx_version}.tar.gz && cd nginx-${nginx_version} 
    ./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
    --with-http_realip_module && make && make install
    ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin
    /usr/local/nginx/sbin/nginx -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！"
    rm -rf $dir/nginx-*
    cat <<EOF > /lib/systemd/system/nginx.service
    [Unit]
    Description=nginx service
    After=network.target
    [Service]
    Type=forking
    ExecStart=/usr/local/nginx/sbin/nginx
    ExecReload=/usr/local/nginx/sbin/nginx -s reload
    ExecStop=/usr/local/nginx/sbin/nginx -s quit
    PrivateTmp=true
    [Install]
    WantedBy=multi-user.target
EOF
systemctl enable nginx.service && systemctl start nginx.service
}

tomcat(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/tomcat ] && echoRed "检测到/usr/local下已安装tomcat，故而退出！" && rm -rf $dir/apache-tomcat-* && exit 1
    wget -nc https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.40/bin/apache-tomcat-9.0.40.tar.gz && tar xf apache-tomcat-9.0.40.tar.gz && mv apache-tomcat-9.0.40 /usr/local/tomcat
    cat <<EOF > /etc/rc.d/rc.local
    export JAVA_HOME=/usr/local/jdk-13
    /usr/local/tomcat/bin/startup.sh start
EOF
    /usr/local/tomcat/bin/startup.sh start &> /dev/null && chmod 777 /etc/rc.d/rc.local && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！"
    rm -rf $dir/apache-tomcat-*
}

jdk13(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    java -version &> /dev/null && echoRed "检测到系统中有java命令，故而退出！" && exit 1
    wget -nc https://mirrors.huaweicloud.com/java/jdk/13+33/jdk-13_linux-x64_bin.tar.gz && tar xf jdk-13_linux-x64_bin.tar.gz -C /usr/local/
    echo 'export JAVA_HOME=/usr/local/jdk-13' >> /etc/profile && echo 'export JRE_HOME=/${JAVA_HOME}' >> /etc/profile && echo 'export CLASSPATH=.:${JAVA_HOME}/libss:${JRE_HOME}/lib' >> /etc/profile && echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> /etc/profile&& source /etc/profile
    /usr/local/jdk-13/bin/java -version &> /dev/null && source /etc/profile && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
    rm -rf $dir/jdk-*.tar.gz 
}
mysql(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/mysql ] && echoRed "检测到/usr/local下已安装mysql，故而退出！" && rm -rf $dir/mysql-* && exit 1
    wget -nc https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.20.tar.gz && mqnu=`cat /etc/passwd | grep mysql |wc -l`
    if [ $mqnu -ne 1 ];then
        echoRed "mysql用户不存在，新建用户" && groupadd mysql && useradd -g mysql -s /sbin/nologin mysql
    else
        echoRed "mysql已经存在"
    fi
    yum install gcc gcc-c++ autoconf automake zlib* libxml* ncurses-devel libtool-ltdl-devel* make cmake cmake3 -y
    [ ! -d /usr/local/mysql/data ] && mkdir -p /usr/local/mysql/data && chown -R mysql.mysql /usr/local/mysql
    echoGreen "开始编译安装！！" && tar -xf mysql-8.0.20.tar.gz && cd mysql-8.0.20 && cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci && make && make install
    echoGreen "注册为服务！！" && cd /usr/local/mysql/scripts && ./mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
    cd /usr/local/mysql/support-files && cp mysql.server /etc/rc.d/init.d/mysql && yes | cp my-default.cnf /etc/my.cnf && chkconfig --add mysql && chkconfig mysql on && service mysql start
    echo 'PATH=/usr/local/mysql/bin:$PATH' >> /etc/profile
    echo 'export PATH' >> /etc/profile && source /etc/profile
    /usr/local/mysql/bin/mysql -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
    source /etc/profile 
}
zabbix(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    zabbix_agentd -V &> /dev/null && echoRed "检测到系统中有zabbix-agentd命令，故而退出！" && rm -rf $dir && exit 1
    wget $ip/pack/zabbix-agent-3.4.11-1.el7.x86_64.rpm && yum -y install $dir/zabbix-agent-3.4.11-1.el7.x86_64.rpm
    #修改相应的配置文件
    sed -i "s/^Server=.*/Server=$zabbixserver/g"  /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^ServerActive=.*/ServerActive=$zabbixserver/g"  /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^Hostname=.*/Hostname=$(hostname -I)/g"  /etc/zabbix/zabbix_agentd.conf
    systemctl enable zabbix-agent && systemctl restart zabbix-agent
    zabbix_agentd -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
    rm -rf $dir
}

#chushihua
allnewcentos(){
    yum install -y epel-release && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    yum clean all && yum makecache fast && yum install wget curl net-tools vim lrzsz ntpdate  -y
    timedatectl set-timezone Asia/Shanghai && /usr/sbin/ntpdate  -u ntp1.aliyun.com  &> /dev/null &
    echo "export  HISTTIMEFORMAT=\"`whoami` : %F %T :\""  >>  /etc/profile   && source /etc/profile
    #防火墙
    getenforce && setenforce 0 && sed -i  's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/selinux/config
    systemctl status firewalld && systemctl stop firewalld && systemctl disable firewalld && systemctl status firewalld
    sed -i 's/\\u@\\h\ /\\u@\\H\ /g' /etc/bashrc
    echo -e  "root soft nofile 65535\nroot hard nofile 65535\n* soft nofile 65535\n* hard nofile 65535\n"     >> /etc/security/limits.conf
    sed -i 's#4096#65535#g' /etc/security/limits.d/20-nproc.conf
    #调用模板脚本
    newvitrulhost
    echo
}

changeipaddress(){
    changeip=$(whiptail --title "更改IP" --inputbox "请输入新的IP地址" 10 60 `hostname -I` 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        whiptail --title "Message" --msgbox "IP地址将由\n$(hostname -I)\n改为:\n$changeip\n" 10 60
        #判断IP是否
        if echo $changeip | grep "^\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}$";then
            #判断文件是否规范
            [ ! -e /etc/sysconfig/network-scripts/ifcfg-eth0 ]   && echo -e "\n网卡配置文件不规范，请检查 ：\n  /etc/sysconfig/network-scripts/ifcfg-eth0\n"  &&  rm -rf $dir  &&  exit 1
            #判断IP是否可用
            ping -c 2 $changeip  > /dev/null && echo -e "\n[$changeip]\n 该IP已在使用中，请检查\n"   && rm -rf $dir && exit 1 || echo "该IP可用"
            #执行
            #       echo "$(hostname -I) >>> $changeip"
            sed -i 's/dhcp/static/i'  /etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^IPADDR  /etc/sysconfig/network-scripts/ifcfg-eth0 &&    sed -i "s/^IPADDR=.*/IPADDR=$changeip/g"  /etc/sysconfig/network-scripts/ifcfg-eth0 || echo "IPADDR="$changeip >>/etc/sysconfig/network-scripts/ifcfg-eth0
            sed -i "s/^NETMASK=.*//g" /etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^PREFIX  /etc/sysconfig/network-scripts/ifcfg-eth0 &&  sed -i "s/^PREFIX=.*/PREFIX=24/g" /etc/sysconfig/network-scripts/ifcfg-eth0 || echo "PREFIX=24" >>/etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^GATEWAY /etc/sysconfig/network-scripts/ifcfg-eth0 &&  sed -i "s/^GATEWAY=.*/GATEWAY=$(echo $changeip|awk -F'.' '{print $1"."$2"."$3}').254/g" /etc/sysconfig/network-scripts/ifcfg-eth0||echo "GATEWAY="$(echo $changeip | awk -F'.' '{print $1"."$2"."$3}')".254" >>/etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^DNS=  /etc/sysconfig/network-scripts/ifcfg-eth0 &&  sed -i "s/^DNS=.*//g" /etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^DNS1=  /etc/sysconfig/network-scripts/ifcfg-eth0 &&  sed -i "s/^DNS1=.*/DNS1=100.100.2.136/g" /etc/sysconfig/network-scripts/ifcfg-eth0 || echo "DNS1=100.100.2.136" >>/etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^DNS2=  /etc/sysconfig/network-scripts/ifcfg-eth0 &&  sed -i "s/^DNS2=.*/DNS2=100.100.2.138/g" /etc/sysconfig/network-scripts/ifcfg-eth0 || echo "DNS2=100.100.2.138" >>/etc/sysconfig/network-scripts/ifcfg-eth0
            grep ^DNS3=  /etc/sysconfig/network-scripts/ifcfg-eth0 &&  sed -i "s/^DNS3=.*/DNS3=114.114.114.114/g" /etc/sysconfig/network-scripts/ifcfg-eth0 || echo "DNS3=114.114.114.114" >>/etc/sysconfig/network-scripts/ifcfg-eth0
            sed -i "s/^Hostname=.*/Hostname=$changeip/g"  /etc/zabbix/zabbix_agentd.conf
            systemctl restart zabbix-agent
            echo -e "\n修改完毕，请手动重启网卡:\n    systemctl restart network\n"
            #systemctl restart network
            rm -rf $dir
        else
            echo "输入的IP不合法"
        fi
    else
        xuanxiang
    fi
}
changehostname(){
    CHANGENAME=$(whiptail --title "更改主机名" --inputbox "请输入新的主机名，用-来连接" 10 60 `hostname` 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        whiptail --title "Message" --msgbox "主机名由\n$(hostname)\n改为:\n$CHANGENAME\n" 10 60
        # whiptail --title "Yes/No Box" --yesno "Choose between Yes and No." --msgbox "主机名将由\n$(hostname)\n改为:\n\"$NAME\"\n""asdasdasd"  10 60
        hostnamectl set-hostname $CHANGENAME
        echo "hostname :  $(hostname)"
    else
        #echo "You chose Cancel."
        xuanxiang
    fi
}

alili(){
    #root用户操作
    yum -y install lrzsz net-tools vim curl wget unzip gunzip git mysql expect ntpdate
    sed -i 's/HISTSIZE=1000/HISTSIZE=5000/g' /etc/profile
    sed -i 's/#Port 22/Port 10036/g' /etc/ssh/sshd_config && systemctl restart sshd
    echo "0 */2 * * *  /usr/sbin/ntpdate  -u ntp1.aliyun.com  &> /dev/null # ntpdate" >> /var/spool/cron/root
    echoGreen "--------------------------------------------------------------------------------------------------------"
    echoRed "服务器已初始化完毕，所做事情：1，更改默认22端口。2，更改历史命令条数与显示规则。3，安装基础软件。4，时间同步。"
    echoGreen "--------------------------------------------------------------------------------------------------------"
}

A(){
    echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\n$OPTION\n，\n现\n在\n开\n始\n安\n装\n$OPTION\n****  \e[39m"
}


#---------------------------------------------------------------------------------------------------------------------------------------------
#               二级菜单
#---------------------------------------------------------------------------------------------------------------------------------------------

anzhuang(){
    OPTION=$(whiptail --title "运维外挂-安装脚本" --menu "请选择想要安装的项目，上下键进行选择，回车即安装，左右键可选择<Cancel>返回上层！" 25 55 15 \
        "1" "nginx-1.18.0" \
        "2" "jdk-13" \
        "3" "tomcat-9.0.40" \
        "4" "mysql-8.0.20" \
        "5" "zabbix-agent-5.0" \
        "6" "暂时未定义"  3>&1 1>&2 2>&3  )
    case $OPTION in
    1)
        A && nginx
        ;;
    2)
        A && jdk13
        ;;
    3)
        A && tomcat
        ;;
    4)
        A && mysql
        ;;
    5)
        A && zabbix
        ;;
    6)
        echo -e  "\e[36m ****您选择的安装项目暂时未定义！****\e[39m" && exit 1
        ;;
    *) 
        xuanxiang
        ;;
    esac
}

chushihua(){
    OPTION=$(whiptail --title "运维外挂-初始化菜单" --menu "请选择想要初始化的选项，上下键进行选择，回车即运行，左右键可选择<Cancel>返回上层！" 25 50 10 \
    "1" "虚拟机 moban clone host" \
    "2" "init a new CeontOS" \
    "3" "zabbix agent" \
    "4" "vmtools" \
    "5" "change ip address" \
    "6" "change hostname"  \
    "7" "aliyun init" 3>&1 1>&2 2>&3 )

    case $OPTION in
    1)
        A && sleep 3 && newvitrulhost
        ;;
    2)
        A && sleep 3 && allnewcentos
        ;;
    3)
        A && sleep 3 && zabbix
        ;;
    4)
        A && changeipaddress
        ;;
    5)
        A && changehostname
        ;;
    6)
        A && alili
        ;;
    *) 
        rm -rf $dir && xuanxiang
        ;;
    esac
}

#---------------------------------------------------------------------------------------------------------------------------------------------
#               入口菜单
#---------------------------------------------------------------------------------------------------------------------------------------------
xuanxiang(){
    OPTION=$(whiptail --title "运维外挂-一步到位" --menu "请选择想要操作的菜单，回车即可进入！" 30 60 6 \
    "1" "安装(install service)" \
    "2" "初始化(new initialization)"   3>&1 1>&2 2>&3 )

    case $OPTION in
    1)
        anzhuang 
        ;;
    2)
        chushihua
        ;;
    *) 
        rm -rf $dir && echo "You chose Cancel."
        ;;
    esac
}

#调用首页
xuanxiang
