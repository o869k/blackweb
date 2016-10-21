#!/bin/bash
### BEGIN INIT INFO
# Provides:          blackweb
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       blackweb for Squid
# by:	             maravento.com, novatoz.com
### END INIT INFO

# CREATE /etc/acl
if [ ! -d /etc/acl ]; then mkdir -p /etc/acl; fi

# GIT CLONE BLACLISTWEB
git clone https://github.com/maravento/blackweb

# CHECKSUM AND COPY /etc/acl
a=$(md5sum blackweb/blackweb.tar.gz | awk '{print $1}')
b=$(cat blackweb/blackweb.md5 | awk '{print $1}')

if [ "$a" = "$b" ]
then 
	tar -C blackweb -xvzf blackweb/blackweb.tar.gz >/dev/null 2>&1
	cp -f blackweb/{blackweb,blackdomains,whitedomains}.txt /etc/acl >/dev/null 2>&1
  	rm -rf blackweb
	date=`date +%d/%m/%Y" "%H:%M:%S`
	echo "<--| Blackweb for Squid: ejecucion $date |-->" >> /var/log/syslog.log
else
	rm -rf blackweb
	date=`date +%d/%m/%Y" "%H:%M:%S`
	echo "<--| Blackweb for Squid: abortada $date Verifique su conexion de internet |-->" >> /var/log/syslog.log
	exit
fi
