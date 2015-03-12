#!/bin/bash

SCRIPT_VERSION=0.1

echo "-"
echo cuckooautoinstall Running Version: $SCRIPT_VERSION ....
echo David Reguera Garcia aka Dreg - buguroo Offensive Security https://buguroo.com/ 
echo "-"
echo Contact: dreg@fr33project.org / dreguera@buguroo.com
echo "-"

set -x 

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=`echo $DISTRIB_ID | tr '[:upper:]' '[:lower:]'`
    VER=`echo $DISTRIB_RELEASE | tr '[:upper:]' '[:lower:]'`
elif [ -f /etc/debian_version ]; then
    OS=debian
    VER=$(cat /etc/debian_version | tr '[:upper:]' '[:lower:]')
elif [ -f /etc/redhat-release ]; then
    # TODO
    ...
else
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    VER=$(uname -r | tr '[:upper:]' '[:lower:]')
fi

CODENAME=`cat /etc/*-release | grep "VERSION=" | tr '[:upper:]' '[:lower:]'`
CODENAME=${CODENAME##*\(}
CODENAME=${CODENAME%%\)*}

echo $OS $VER $ARCH $CODENAME
    
    if ! hash sudo 2>/dev/null; then
        echo install sudo from the root account: apt-get install sudo
        exit
    fi

    sudo apt-get -y install python-pip python-sqlalchemy mongodb python-bson python-dpkt python-jinja2 python-magic python-gridfs python-libvirt python-bottle python-pefile python-chardet
    sudo pip install django
    sudo pip install pymongo -U
    sudo apt-get -y install git
    sudo apt-get -y install build-essential
    sudo apt-get -y install autoconf automake libtool
    sudo apt-get -y install emacs
    sudo apt-get -y install curl
    # Install Sublime Text
    sudo cd /opt
    sudo wget http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2%20x64.tar.bz2
    sudo tar xf Sublime\ Text\ 2.0.2\ x64.tar.bz2 
    sudo ln -s /opt/Sublime\ Text\ 2/sublime_text /usr/bin/sublime

    #jansson
    git clone https://github.com/akheron/jansson
    cd jansson
    autoreconf -vi
    ./configure
    make
    make check
    sudo make install
    sudo autoreconf -i --force
    cd ..
    #jansson end

    sudo apt-get -y install libcurl4-gnutls-dev libmagic-dev python-dev

    #yara
    git clone https://github.com/plusvic/yara
    cd yara
    ./bootstrap.sh
    sudo autoreconf -i --force
    ./configure --enable-cuckoo --enable-magic
    make
    make install
    cd yara-python/
    python setup.py build
    sudo python setup.py install
    cd ..
    cd ..
    #yara end

    #ssdeep
    wget -c -L http://sourceforge.net/projects/ssdeep/files/latest/download?source=files -O ssdeep.tar.gz
    tar -zxvf ssdeep.tar.gz
    cd `tar tzf ssdeep.tar.gz | sed -e 's@/.*@@' | uniq`
    ./configure
    make
    make check
    sudo make install
    sudo ldconfig
    cd ..
    #ssdeep end

    #pydeep
    wget -c https://github.com/kbandla/pydeep/archive/master.zip
    unzip -o master.zip
    cd pydeep-master
    python setup.py build
    sudo python setup.py install
    cd ..
    #pydeep end

    #virtualbox
    VIRTUALBOX_REP="deb http://download.virtualbox.org/virtualbox/debian $CODENAME contrib"
    if ! grep -q "$VIRTUALBOX_REP" /etc/apt/sources.list; then
        echo $VIRTUALBOX_REP >> /etc/apt/sources.list
    fi
    wget -c https://www.virtualbox.org/download/oracle_vbox.asc
    sudo apt-key add oracle_vbox.asc
    sudo apt-get update
    sudo apt-get -y install virtualbox
    sudo apt-get -y install dkms

    sudo vboxmanage hostonlyif create
    sudo iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A POSTROUTING -t nat -j MASQUERADE
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo adduser  --disabled-password -gecos "" cuckoo
    sudo usermod -G vboxusers cuckoo
    #virtualbox end

    #tcpdump
    sudo apt-get -y install tcpdump
    sudo apt-get -y install libcap2-bin 
    sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
    #tcpdump end

    #cuckoo
    git clone git://github.com/cuckoobox/cuckoo.git
    #cuckoo end

    #django fix
    DJANGO_VERSION=`python -c "import django; print(django.get_version())"`
    verlte 1.5 $DJANGO_VERSION && FIX_DJANGO=false || FIX_DJANGO=true
    if [ "$FIX_DJANGO" = true ]; then
        cat cuckoo/web/web/settings.py | grep -A1 "TEMPLATE_DIRS = (" | cut -d# -f2 | grep "templates" | grep "(" | grep ")"
        if [ $? -ne 0 ]; then
            echo "Fixing settings.py...."
            sed -i '/TEMPLATE_DIRS/{ N; s/.*/TEMPLATE_DIRS = \( \("templates"\),/; }' cuckoo/web/web/settings.py
        fi
    fi
    #django fix end

    #enable mongodb
    cat cuckoo/conf/reporting.conf | grep -A1 "\[mongodb\]" | cut -d# -f2 | grep "enabled = no" 
    if [ $? -eq 0 ]; then
        echo "Enabling mongodb in reporting.conf"
        sed -i '/\[mongodb\]/{ N; s/.*/\[mongodb\]\nenabled = yes/; }' cuckoo/conf/reporting.conf
    fi
    #enable mongodb end

    # Download XP box 
    sudo mkdir /vagrant/vm
    sudo cd /vagrant/vm
    sudo curl -O https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE6/Mac/IE6.XP.For.Mac.VirtualBox.zip
    sudo cd /vagrant/vm
    sudo unzip *zip

    # sudo -s
    # su cuckoo
    # VBoxManage import "/vagrant/vm/IE6.WinXP/IE6 - WinXP.ova"   
    # vboxmanage modifyvm "IE6 - WinXP" --hostonlyadapter1 vboxnet
    # vboxmanage startvm "IE6 - WinXP"

