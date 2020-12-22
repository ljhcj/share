#!/bin/bash
##set color##
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }
dir=`pwd`
nginx_version=1.18.0
#判断一下当前用户
if [ "`whoami`" != "root" ];then
    echoRed "注意：当前系统用户非root用户，将无法执行安装等事宜！" && exit 1
fi
#---------------------------------------------------------------------------------------------------------------------------------------------
#               三级方法
#---------------------------------------------------------------------------------------------------------------------------------------------
S(){
    echo "-----------------------------------------------------"
    echo "运行source /etc/profile && source /etc/bashrc安装完成！"
    echo "-----------------------------------------------------"
}
#install
nginx(){
    cd $dir && wget -V &> /dev/null || yum -y install wget
    [ -d /usr/local/nginx ] && echoRed "检测到/usr/local下已安装ngixn，故而退出!" && rm -rf $dir && exit 1
    [ ! -f $dir/nginx-${nginx_version}.tar.gz ] && wget -nc http://nginx.org/download/nginx-${nginx_version}.tar.gz
    yum install gcc gcc-c++ pcre pcre pcre-devel zlib zlib-devel openssl openssl-devel -y
    tar -xvzf nginx-${nginx_version}.tar.gz && cd nginx-${nginx_version} 
    ./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
    --with-http_realip_module && make && make install
    ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin
    /usr/local/nginx/sbin/nginx -V &> /dev/null && echoGreen "已完成安装，可尽情享用！" || echoYellow "可能安装有问题，请检查！" 
    rm -rf $dir
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

A(){
    echo -e  "\e[36m ****\n您\n选\n择\n安\n装\n的\n是\n$OPTION\n，\n现\n在\n开\n始\n安\n装\n$OPTION\n****  \e[39m"
}


#---------------------------------------------------------------------------------------------------------------------------------------------
#               二级菜单
#---------------------------------------------------------------------------------------------------------------------------------------------

anzhuang(){
    OPTION=$(whiptail --title "运维外挂-安装脚本" --menu "请选择想要安装的项目，上下键进行选择，回车即安装，左右键可选择<Cancel>返回上层！" 25 55 15 \
        "1" "nginx" \
        "2" "jdk" \
        "3" "tomcat" \
        "4" "mysql" \
        "5" "zabbix-agent" \
        "6" "暂时未定义"  3>&1 1>&2 2>&3  )
    case $OPTION in
    1)
        A && nginx
        ;;
    2)
        A && jdk8
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
