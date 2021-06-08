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
A(){
    echo "--------------------------------------------------------------------------------"
    echo -e "\033[44;30m请运行source /etc/profile && source ~/.bash_profile安装完成！\033[0m"
    echo "--------------------------------------------------------------------------------"
}
#install
nginx(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/nginx ] && echoRed "检测到/usr/local下已安装nginx，故而退出!" && rm -rf $dir/nginx-* && exit 1
    [ ! -f $dir/nginx-${nginx_version}.tar.gz ] && wget -nc http://nginx.org/download/nginx-${nginx_version}.tar.gz
    yum install gcc gcc-c++ pcre pcre pcre-devel zlib zlib-devel openssl openssl-devel -y
    tar -xvzf nginx-${nginx_version}.tar.gz && cd nginx-${nginx_version} 
    ./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
    --with-http_realip_module && make && make install
    ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin
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
    firewall-cmd --permanent --add-port=80/tcp && firewall-cmd --reload
    /usr/local/nginx/sbin/nginx -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！"
    rm -rf $dir/nginx-*
}

nginx1.16.0(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/nginx ] && echoRed "检测到/usr/local下已安装nginx，故而退出!" && rm -rf $dir/nginx-* && exit 1
    wget -nc https://github.com/ljhcj/share/raw/master/nginx-1.16.0.tar.gz && sudo tar -xvf nginx-1.16.0.tar.gz -C /usr/local/
    yum install gcc gcc-c++ pcre pcre pcre-devel zlib zlib-devel openssl openssl-devel -y
    cd /usr/local/
    sudo chown www:www -R client_body_temp/ && sudo chown www:www -R fastcgi_temp/ && sudo chown www:www -R proxy_temp/ && sudo chown www:www -R scgi_temp/ && sudo chown www:www -R uwsgi_temp/
    cd /usr/local/nginx/sbin/ && sudo cp nginx /etc/init.d/ && sudo mkdir -p /wwwroot/logs/nginx/ && sudo chown www:www -R /wwwroot/logs/nginx/
    sudo ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx && sudo /etc/init.d/nginx
    /usr/local/nginx/sbin/nginx -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！"
}

tomcat(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/tomcat ] && echoRed "检测到/usr/local下已安装tomcat，故而退出！" && rm -rf $dir/apache-tomcat-* && exit 1
    wget -nc https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.40/bin/apache-tomcat-9.0.40.tar.gz && tar -xvzf apache-tomcat-9.0.40.tar.gz && mv apache-tomcat-9.0.40 /usr/local/tomcat
    cp /usr/local/tomcat/bin/catalina.sh /etc/init.d/ && mv /etc/init.d/catalina.sh /etc/init.d/tomcat && chmod 777 /etc/init.d/tomcat
    sed -i '2a#chkconfig: 2345 10 90' /etc/init.d/tomcat && sed -i '3a#description: tomcat service' /etc/init.d/tomcat && sed -i '4aexport CATALINA_HOME=/usr/local/tomcat/' /etc/init.d/tomcat && sed -i '5aexport JAVA_HOME=/usr/local/jdk-13' /etc/init.d/tomcat && sed -i '6aexport JAVA_OPTS="$JAVA_OPTS -Duser.timezone=Asia/shanghai"' /etc/init.d/tomcat
    chkconfig --add tomcat && systemctl start tomcat && chmod 777 /etc/rc.d/rc.local && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！"
    rm -rf $dir/apache-tomcat-*
}

jdk13(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    java -version &> /dev/null && echoRed "检测到系统中有java命令，故而退出！" && exit 1
    wget -nc https://mirrors.huaweicloud.com/java/jdk/13+33/jdk-13_linux-x64_bin.tar.gz && tar xf jdk-13_linux-x64_bin.tar.gz -C /usr/local/
    echo 'export JAVA_HOME=/usr/local/jdk-13' >> ~/.bash_profile && echo 'export JRE_HOME=/${JAVA_HOME}' >> ~/.bash_profile && echo 'export CLASSPATH=.:${JAVA_HOME}/libss:${JRE_HOME}/lib' >> ~/.bash_profile && echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> ~/.bash_profile && source ~/.bash_profile
    /usr/local/jdk-13/bin/java -version &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
    A && rm -rf $dir/jdk-*.tar.gz
}

mysql(){
    cd $dir && wget -V &> /dev/null || yum -y install wget lsof bc
    wget -nc http://ftp.ntu.edu.tw/MySQL/Downloads/MySQL-5.7/mysql-5.7.31-linux-glibc2.12-x86_64.tar.gz && wget -nc https://gitee.com/ljhcj/share/raw/master/fast_install/install_mysql.sh && wget -nc https://gitee.com/ljhcj/share/raw/master/fast_install/my.cnf
    chmod +x install_mysql.sh && sed -i 's/\r$//' install_mysql.sh && $dir/install_mysql.sh && ln /usr/local/mysql/bin/mysql /usr/bin/mysql
    /usr/local/mysql/bin/mysql -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
}

redis(){
    cd $dir && wget -V &> /dev/null || yum -y install wget gcc gcc-c++ centos-release-scl && yum install devtoolset-7-gcc* -y && scl enable devtoolset-7 bash && echo "source /opt/rh/devtoolset-7/enable" >> ~/.bash_profile && source /opt/rh/devtoolset-7/enable
    redis-server -v &> /dev/null && echoRed "检测到系统中有redis-server命令，故而退出！" && rm -rf $dir/redis-* && exit 1
    wget -nc http://download.redis.io/releases/redis-6.0.6.tar.gz && tar -xf redis-6.0.6.tar.gz -C /usr/local/ && mv /usr/local/redis-6.0.6 /usr/local/redis && cd /usr/local/redis && make && make install
    sed -i 's#daemonize no#daemonize yes#g' /usr/local/redis/redis.conf && sed -i 's#loglevel notice#loglevel warning#g' /usr/local/redis/redis.conf
    ln -s /usr/local/redis/src/redis-server /usr/bin/redis-server && ln -s /usr/local/redis/src/redis-server  /etc/init.d/redis-server
    cat <<EOF > /lib/systemd/system/redis-server.service
    [Unit]
    Description=The redis-server Process Manager
    After=syslog.target network.target
    [Service]
    Type=simple
    PIDFile=/var/run/redis_6379.pid
    ExecStart=/usr/local/redis/redis-server /usr/local/redis/redis.conf
    ExecReload=/bin/kill -USR2 $MAINPID
    ExecStop=/bin/kill -SIGINT $MAINPID
    [Install]
    WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl start redis-server && systemctl enable redis-server
    firewall-cmd --zone=public --add-port=6379/tcp --permanent && firewall-cmd --reload && firewall-cmd --zone=public --query-port=6379/tcp
    /usr/local/redis/src/redis-server /usr/local/redis/redis.conf && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
    rm -rf $dir/redis-*
}

docker(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    /usr/bin/docker -version &> /dev/null && echoRed "检测到系统中有docker命令，故而退出！" && exit 1
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
    curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && mkdir -p /etc/docker
    yum install -y yum-utils device-mapper-persistent-data lvm2 && yum install -y docker-ce docker-ce-cli containerd.io 
    tee /etc/docker/daemon.json <<-'EOF'
    {
      "registry-mirrors": ["https://t2lazqaw.mirror.aliyuncs.com"],
      "exec-opts": ["native.cgroupdriver=systemd"]
    }
EOF
    systemctl daemon-reload && systemctl enable docker && systemctl restart docker
}

#chushihua
allnewcentos(){
    yum install -y epel-release wget && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    yum clean all && yum makecache fast && yum install unzip gunzip curl net-tools vim lrzsz ntpdate centos-release-scl -y && yum install devtoolset-7 -y && scl enable devtoolset-7 bash && yum groupinstall "Development Tools" -y
    timedatectl set-timezone Asia/Shanghai && /usr/sbin/ntpdate  -u ntp1.aliyun.com  &> /dev/null &
    echo "export  HISTTIMEFORMAT=\"`whoami` : %F %T :\""  >>  /etc/profile   && source /etc/profile && echo "source /opt/rh/devtoolset-7/enable" >> ~/.bash_profile
    getenforce && setenforce 0 && sed -i  's/SELINUX=enforcing/SELINUX=disabled/g'  /etc/selinux/config && sed -i '/swap/s/^/#/' /etc/fstab
    systemctl stop firewalld && systemctl disable firewalld
   # firewall-cmd --permanent --add-port=7788/tcp && firewall-cmd --reload
   # sed -i 's/\\u@\\h\ /\\u@\\H\ /g' /etc/bashrc && sed -i 's/HISTSIZE=1000/HISTSIZE=5000/g' /etc/profile && sed -i 's/#Port 22/Port 7788/g' /etc/ssh/sshd_config && systemctl restart sshd
    echo "0 */2 * * *  /usr/sbin/ntpdate  -u ntp1.aliyun.com  &> /dev/null # ntpdate" >> /var/spool/cron/root
    echo -e  "root soft nofile 65535\nroot hard nofile 65535\n* soft nofile 65535\n* hard nofile 65535\n"     >> /etc/security/limits.conf
    sed -i 's#4096#65535#g' /etc/security/limits.d/20-nproc.conf
    echoGreen "--------------------------------------------------------------------------------------------------------"
    echoRed "服务器已初始化完毕，所做事情：1，更改默认22端口。2，更改历史命令条数与显示规则。3，安装基础软件。4，时间同步。"
    echoGreen "--------------------------------------------------------------------------------------------------------"
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

aliyun(){
    #root用户操作
    #root用户操作
    useradd -m -d /home/admin -s /bin/bash admin && useradd -m -d /home/deubg -s /bin/bash debug && useradd -M -s /sbin/nologin www && sudo groupadd docker && sudo usermod -aG docker admin && sudo usermod -aG docker debug
    yum -y install lrzsz net-tools vim curl wget unzip gzip expect ntpdate
    echo "export HISTTIMEFORMAT=\"`whoami` : %F %T :\"" >> /etc/profile && source /etc/profile
    echo "admin ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/admin
    sed -i 's/HISTSIZE=1000/HISTSIZE=5000/g' /etc/profile
cat > /root/.bashrc << EOF
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias untar='tar xvf '
alias grep='grep --color=auto'
alias getpass="openssl rand -base64 20"

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
PS1="\[\e[37;40m\][\[\e[36;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$"
EOF
    source /root/.bashrc
    echo "0 */2 * * *  /usr/sbin/ntpdate  -u ntp1.aliyun.com  &> /dev/null # ntpdate" >> /var/spool/cron/root
#admin init
    echoYellow "开始初始化admin用户"
cat > /home/admin/.bashrc << EOF
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
PS1="\[\e[37;40m\][\[\e[36;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$"
EOF
    chown admin.admin /home/admin/.bashrc

    mkdir /home/admin/.ssh && chmod 700 /home/admin/.ssh
cat > /home/admin/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDL1ELizmbwk3IqubQZSJ1UdSxMfQZqJq4Zh94iZZ5QuwH3xtGPsdMJRgyr1yRWjW22K1F5qVtYhiCtTDeaCcdVJl/E8Vo88g5rdtz2khjiYeIbsPqyth8i8W2tbg1GYoEzwv06y0kAoeZv5NRHKrKSuH95/PskGbJ+LHd0vVLtob46qQLMnZdweN4KnH7jmZ8GAIGtOaYBQvxNc+RGlHzymD45KTAO35qJqeJFVLwBpFg5miM8DSYIbwLb5k7K1yUIQxxUXe8KtyGagjzNjcOeFa03/3Ol69u9DRZwmrB8CJNIz/IH8wxd0gqEPNwGwETT3RVyaX4P8VLXpPBCEcE3 admin@bastion-jenkins-40
EOF
    chmod 700 /home/admin/.ssh/authorized_keys && chown -R admin.admin /home/admin/.ssh
    echoGreen "admin用户初始化完毕！"
#debug init
    echoYellow "开始初始化debug用户"
cat > /home/admin/.bashrc << EOF
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
PS1="\[\e[37;40m\][\[\e[36;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\$"
EOF
    chown debug.debug /home/debug/.bashrc

    mkdir /home/debug/.ssh && chmod 700 /home/debug/.ssh
cat > /home/debug/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC39y6+cDbNjmHwxJlsDiDlG0jV6gG8aqDWpjns3Ah7PHohEmxvpVuFytI4YnMiqTHiUZX+GBT9vjunvConcKmLHIk5RmEL5hIR0/XqdsJJ5lYurI7dIJwD3kZ/TKmOD4zLw0I0UUj2K4C91gz0PtfvXxSspUc702vm8dWDX7ouD3JzdP2bAUINUd+MgCZi69BA1Kv7vpPADW8/QikKGIqxIjJISL5Zxu4Fc7uFR47YnvFHMuSc0XY8P0le1T1MeOT4FP36Av+DMtKM3jJSvMh4xOU3JLyDbYsHMj+fTAPh5iQPOaH0AdebBjyCZ6BL0RJqVtRd0IuDqCZ71w+mveKt debug@bastion-jenkins-40
EOF
    chmod 700 /home/debug/.ssh/authorized_keys && chown -R debug.debug /home/debug/.ssh
    echoGreen "debug用户初始化完毕！"
    echoGreen "-----------------------------------------------------------------------------------------------------------------------------------"
    echoRed "服务器已初始化完毕，所做事情：1，初始化admin、debug、www用户。2，安装基础软件。3，添加admin用户sudo权限。4，更改历史命令条数与显示规则。5，时间同步"
    echoGreen "-----------------------------------------------------------------------------------------------------------------------------------"
}


#---------------------------------------------------------------------------------------------------------------------------------------------
#               二级菜单
#---------------------------------------------------------------------------------------------------------------------------------------------

anzhuang(){
    OPTION=$(whiptail --title "运维外挂-安装脚本" --menu "请选择想要安装的项目，上下键进行选择，回车即安装，左右键可选择<Cancel>返回上层！" 25 55 15 \
        "1" "nginx-1.18.0" \
        "2" "nginx-1.16.0" \
        "3" "jdk-13" \
        "4" "tomcat-9.0.40" \
        "5" "mysql-5.7.31" \
        "6" "redis-6.0.6" \
        "7" "docker" \
        "8" "暂时未定义"  3>&1 1>&2 2>&3  )
    case $OPTION in
    1)
        nginx
        ;;
    2)
        nginx1.6.0
        ;;
    3)
        jdk13
        ;;
    4)
        tomcat
        ;;
    5)
        mysql
        ;;
    6)
        redis
        ;;
    7)
        docker
        ;;
    8)
        echo -e  "\e[36m ****您选择的安装项目暂时未定义！****\e[39m" && exit 1
        ;;
    *) 
        xuanxiang
        ;;
    esac
}

chushihua(){
    OPTION=$(whiptail --title "运维外挂-初始化菜单" --menu "请选择想要初始化的选项，上下键进行选择，回车即运行，左右键可选择<Cancel>返回上层！" 25 50 10 \
    "1" "init a new CeontOS" \
    "2" "change ip address" \
    "3" "change hostname"  \
    "4" "aliyun init" 3>&1 1>&2 2>&3 )

    case $OPTION in
    1)
        allnewcentos
        ;;
    2)
        changeipaddress
        ;;
    3)
        changehostname
        ;;
    4)
        aliyun
        ;;
    *)
        xuanxiang
        ;;
    esac
}

#---------------------------------------------------------------------------------------------------------------------------------------------
#               入口菜单
#---------------------------------------------------------------------------------------------------------------------------------------------
xuanxiang(){
    OPTION=$(whiptail --title "运维外挂-一步到位" --menu \
    "请选择想要操作的菜单，回车即可进入！" 30 60 6 \
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
        echo "You chose Cancel."
        ;;
    esac
}

#调用首页
xuanxiang
