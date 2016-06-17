#!/usr/bin/env /bin/sh

# NOTE: fix for issue https://github.com/mitchellh/vagrant/issues/1673
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
tty -s && mesg n

#set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.


#if [ "$(uname)" != "root" ]; then
#    sudo su
#fi

### FIXES ###
#export LC_ALL="en_US.UTF-8"
#locale-gen en_US.UTF-8
#dpkg-reconfigure locales
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


cd /home/vagrant
CWD=$(pwd)
echo "" >> ./.profile
echo "export LC_ALL=en_US.UTF-8" >> ./.profile
echo "export LANG=en_US.UTF-8" >> ./.profile
echo "" >> ./.profile



####################################################################
### INFORMATION
####################################################################

# + default: all *.conf files placed in /etc/openvpn will be used on startup
# + check status: $ curl https://check.ipredator.se/
# + HOWTOs: https://blog.ipredator.se/howto.html



####################################################################
### ENVIRONMENT VARIABLES
####################################################################
# NOTE: other configs for e.g. NAT or IPv6 can be found here:
# https://beta.ipredator.se/guide/openvpn/settings#openvpn_config_file
IPREDATOR_OPENVPN_CONFIG_URL=https://beta.ipredator.se/static/downloads/openvpn/cli/IPredator-CLI-Password.conf
IPREDATOR_OPENVPN_CONFIG_FILE=ipredator.conf
IPREDATOR_OPENVPN_CREDENTIALS=IPredator.auth

IPREDATOR_FIREWALL_FERM_CONFIG_URL=https://www.ipredator.se/static/downloads/howto/linux_firewall/ferm.conf
IPREDATOR_FIREWALL_FERM_CONFIG_FILE=ferm.conf
IPREDATOR_FIREWALL_FERM_SCRIPT_URL=https://www.ipredator.se/static/downloads/howto/linux_firewall/fermreload.sh
IPREDATOR_FIREWALL_FERM_SCRIPT_FILE=fermreload.sh
IPREDATOR_FIREWALL_FERM_RULES_URL=https://www.ipredator.se/static/downloads/howto/linux_firewall/81-vpn-firewall.rules
IPREDATOR_FIREWALL_FERM_RULES_FILE=81-vpn-firewall.rules


OPENVPN_USERNAME=root
OPENVPN_PATH=/etc/openvpn
FERM_PATH=/etc/ferm
SYSCTL_CONF_PATH_FILE=/etc/sysctl.conf
ULOGD_CONF_PATH_FILE=/etc/ulogd.conf
DNSCRYPT_SERVICE_FILE=dnscrypt-proxy.service
DNSCRYPT_CONF_PATH_FILE=/etc/default/dnscrypt-proxy
DHCPCLIENT_CONF_PATH_FILE=/etc/dhcp/dhclient.conf

SYSTEMD_UNITS_PATH=/etc/systemd/system

BTFSDL_ROOT=${1:-/home/vagrant/btfsdl}
BTFSDL_SERVICE_FILE=btfsdl.service

USERNAME=${2:-root}



####################################################################
### INSTALL ENVIRONMENT
####################################################################
# NOTE: sleeping/pauses tend to make the apt-get installations
# running more stable. (Why? The hell I know! My guess, some async,
# child process or background stuff going on.)

apt-get update -y

# making `add-apt-repository` available again
apt-get -y install software-properties-common
sleep 5

apt-get -y install curl openvpn easy-rsa
sleep 5

echo "ferm ferm/enable boolean false" | debconf-set-selections
apt-get -y install ferm ulogd2 ulogd2-pcap


add-apt-repository -y ppa:anton+/dnscrypt
apt-get update -y
apt-get -y install dnscrypt-proxy
sleep 5

add-apt-repository -y ppa:johang/btfs
apt-get update -y
apt-get -y install btfs
sleep 5

####################################################################
### CONFIGURE ENVIRONMENT
####################################################################
mkdir -p ${BTFSDL_ROOT}
chown ${USERNAME}:${USERNAME} ${BTFSDL_ROOT}


### OPENVPN ###
curl -o ${IPREDATOR_OPENVPN_CONFIG_FILE} ${IPREDATOR_OPENVPN_CONFIG_URL}

# supporting older version of openvpn
#sed -e '/^tls-version-min 1.2/s/^#*/#/' -i ./${IPREDATOR_OPENVPN_CONFIG_FILE}

echo "script-security 2" >> ./${IPREDATOR_OPENVPN_CONFIG_FILE}
echo "up /etc/openvpn/update-resolv-conf" >> ./${IPREDATOR_OPENVPN_CONFIG_FILE}
echo "down /etc/openvpn/update-resolv-conf" >> ./${IPREDATOR_OPENVPN_CONFIG_FILE}
echo "" >> ./${IPREDATOR_OPENVPN_CONFIG_FILE}

cp ./${IPREDATOR_OPENVPN_CONFIG_FILE} ${OPENVPN_PATH}/
cp ${BTFSDL_ROOT}/conf/${IPREDATOR_OPENVPN_CREDENTIALS} ${OPENVPN_PATH}/${IPREDATOR_OPENVPN_CREDENTIALS}

chown ${OPENVPN_USERNAME}:${OPENVPN_USERNAME} ${OPENVPN_PATH}/${IPREDATOR_OPENVPN_CONFIG_FILE}
chown ${OPENVPN_USERNAME}:${OPENVPN_USERNAME} ${OPENVPN_PATH}/${IPREDATOR_OPENVPN_CREDENTIALS}
chmod 400 ${OPENVPN_PATH}/${IPREDATOR_OPENVPN_CONFIG_FILE}
chmod 400 ${OPENVPN_PATH}/${IPREDATOR_OPENVPN_CREDENTIALS}

echo "ifconfig tun0" >> ${CWD}/.profile
echo "ip route show" >> ${CWD}/.profile
echo "sudo iptables -nL -v" >> ${CWD}/.profile



### FIREWALL ### (src: https://blog.ipredator.se/linux-firewall-howto.html)
curl -o ${IPREDATOR_FIREWALL_FERM_CONFIG_FILE} ${IPREDATOR_FIREWALL_FERM_CONFIG_URL}

. ${BTFSDL_ROOT}/conf/params

# enabling torrents (src: https://blog.ipredator.se/howto/restricting-transmission-to-the-vpn-interface-on-ubuntu-linux.html)
sed -i \
    -e '/^@def $PORT_DNS = 53;/c\@def $PORT_DNS = ( 53 443 );' \
    -e 's/eth0/enp0s3/g' \
    -e '/^\@def $PORT_WEB/a \
@def $PORTS_TRACKER = ( '"${PORTS_TRACKER}"'); \
\
# Ports btfs is allowed to use.\
\@def $PORT_BTFS = '"(${PORT_MIN}:${PORT_MAX} ${PORT_BTFS})"';' \
    -e '0,/chain OUTPUT {/s/chain OUTPUT {/chain INPUT {\
               interface $DEV_VPN {\
                    proto (tcp udp) dport $PORT_BTFS ACCEPT;\
                }\
            }\n            &/' \
    -e '/proto (tcp udp) daddr ( $IP_DNS_VPN $IP_DNS_IPR_PUBLIC ) dport $PORT_DNS ACCEPT;/ a\
                    proto (tcp udp) dport $PORT_BTFS ACCEPT;' \
    -e '/proto tcp dport $PORT_WEB ACCEPT;/ a\
                    proto udp dport $PORTS_TRACKER ACCEPT;' ./${IPREDATOR_FIREWALL_FERM_CONFIG_FILE}

mv ${FERM_PATH}/${IPREDATOR_FIREWALL_FERM_CONFIG_FILE} ${FERM_PATH}/${IPREDATOR_FIREWALL_FERM_CONFIG_FILE}.default
cp ./${IPREDATOR_FIREWALL_FERM_CONFIG_FILE} ${FERM_PATH}/${IPREDATOR_FIREWALL_FERM_CONFIG_FILE}
chmod 644 ${FERM_PATH}/${IPREDATOR_FIREWALL_FERM_CONFIG_FILE}
chown root:adm ${FERM_PATH}/${IPREDATOR_FIREWALL_FERM_CONFIG_FILE}

sed -i '/ENABLED="no"/ c\ENABLED="yes"' /etc/default/ferm

curl -o ${IPREDATOR_FIREWALL_FERM_RULES_FILE} ${IPREDATOR_FIREWALL_FERM_RULES_URL}
cp ./${IPREDATOR_FIREWALL_FERM_RULES_FILE} /etc/udev/rules.d/${IPREDATOR_FIREWALL_FERM_RULES_FILE}
chmod 644 /etc/udev/rules.d/${IPREDATOR_FIREWALL_FERM_RULES_FILE}
chown root:root /etc/udev/rules.d/${IPREDATOR_FIREWALL_FERM_RULES_FILE}

curl -o ${IPREDATOR_FIREWALL_FERM_SCRIPT_FILE} ${IPREDATOR_FIREWALL_FERM_SCRIPT_URL}
cp ./${IPREDATOR_FIREWALL_FERM_SCRIPT_FILE} /usr/local/bin/${IPREDATOR_FIREWALL_FERM_SCRIPT_FILE}
chmod 555 /usr/local/bin/${IPREDATOR_FIREWALL_FERM_SCRIPT_FILE}
#/etc/init.d/udev reload

# logging_dropped_packages
sed -i \
    -e '/^#plugin=.*ulogd_output_PCAP.so/s/^#//' \
    -e '/^#stack=log2:NFLOG,base1:BASE,pcap1:PCAP/s/^#//' \
    -e '/^file="\/var\/log\/ulog\/syslogemu.log"/s/^#*/#/' \
    -e '/^#file="\/var\/log\/ulog\/syslogemu.log"/a file="\/dev\/null"' ${ULOGD_CONF_PATH_FILE}

#/etc/init.d/ulogd2 restart



### Optimizing system for torrenting ###
echo "" >> ${SYSCTL_CONF_PATH_FILE}
echo "# optimizing system for torrenting" >> ${SYSCTL_CONF_PATH_FILE}
echo "net.ipv4.ip_local_port_range = ${PORT_MIN} ${PORT_MAX}" >> ${SYSCTL_CONF_PATH_FILE}
echo "net.netfilter.nf_conntrack_generic_timeout = 60" >> ${SYSCTL_CONF_PATH_FILE}
echo "net.netfilter.nf_conntrack_tcp_timeout_established = 600" >> ${SYSCTL_CONF_PATH_FILE}
echo "net.netfilter.nf_conntrack_tcp_timeout_time_wait = 1" >> ${SYSCTL_CONF_PATH_FILE}
echo "net.netfilter.nf_conntrack_max = 1048576" >> ${SYSCTL_CONF_PATH_FILE}



### DNS ###
cp ${BTFSDL_ROOT}/lib/${DNSCRYPT_SERVICE_FILE} ${SYSTEMD_UNITS_PATH}/${DNSCRYPT_SERVICE_FILE}
chown root:root ${SYSTEMD_UNITS_PATH}/${DNSCRYPT_SERVICE_FILE}
systemctl daemon-reload



id -u ${USERNAME} &>/dev/null || adduser ${USERNAME} --shell /bin/bash --disabled-password --disabled-login --gecos ""


cp ${BTFSDL_ROOT}/lib/${BTFSDL_SERVICE_FILE} ${SYSTEMD_UNITS_PATH}/${BTFSDL_SERVICE_FILE}
chown root:root ${SYSTEMD_UNITS_PATH}/${BTFSDL_SERVICE_FILE}
systemctl enable ${BTFSDL_SERVICE_FILE}




####################################################################
### POST PROVISION
####################################################################

sudo poweroff && exit 0;
