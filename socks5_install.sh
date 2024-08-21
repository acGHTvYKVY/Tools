#!/bin/sh
apt install dante-server -y && mkdir /var/log/danted/
cat << EOF > /etc/danted.conf
logoutput: syslog stdout /var/log/danted/danted.log
user.privileged: root
user.unprivileged: nobody
internal: 0.0.0.0 port = 60120
external: eth0
socksmethod: username
clientmethod: none
user.libwrap: nobody
client pass {
        from: 0/0 to: 0/0
}
socks pass {
        from: 0/0 to: 0/0
}
EOF
useradd -r -s /bin/false sproxy
chpasswd -e <<< 'sproxy:$6$7b7sYf/Z$dWJsTTLR.o06DlbnGVOXRuQbXdUrsKbNdwYaY.vNlcwfDUOEYU93753/V3ELZ.jiuogqWrk1yphAh3AdzybPj0'

service danted start
systemctl enable danted
info() {
	echo -e "proxy_hosts: $(curl -s cip.cc|grep IP)"
	echo -e "proxy_password: BFk8ysza" 
	echo -e "proxy_port: 60120"
}
service danted restart
info
