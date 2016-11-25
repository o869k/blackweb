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

blpath=~/blackweb

# DEL REPOSITORY
if [ -d $blpath ]; then rm -rf $blpath; fi

# GIT CLONE BLACKWEB
echo "Download Blackweb Project..."
git clone https://github.com/maravento/blackweb.git
echo "OK"

# CREATE DIR
if [ ! -d /etc/acl ]; then mkdir -p /etc/acl; fi

# CHECKSUM AND COPY /etc/acl
echo "Checksum and Transfer Blackweb..."
a=$(md5sum $blpath/blackweb.tar.gz | awk '{print $1}')
b=$(cat $blpath/blackweb.md5 | awk '{print $1}')

if [ "$a" = "$b" ]
then 
	tar -C $blpath -xvzf $blpath/blackweb.tar.gz >/dev/null 2>&1
	cp -f $blpath/{blackweb,blackdomains,whitedomains}.txt /etc/acl >/dev/null 2>&1
  	rm -rf $blpath
	date=`date +%d/%m/%Y" "%H:%M:%S`
	echo "Blackweb for Squid: $date" >> /var/log/syslog.log
    echo "Done" 
else
	rm -rf $blpath
	date=`date +%d/%m/%Y" "%H:%M:%S`
	echo "Blackweb for Squid: Abort $date Check Internet Connection" >> /var/log/syslog.log
    echo "Abort. Check /var/log/syslog.log"
	exit
fi
