#!/bin/bash
### BEGIN INIT INFO ###
# Provides:          Blackweb Update for Squid
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
# Authors:           Maravento.com and Novatoz.com
# spript route:		 /etc/init.d
### END INIT INFO ###

blpath=~/blackweb

# DEL REPOSITORY
if [ ! -d $blpath ]; then rm -rf $blpath; fi

# GIT CLONE BLACLISTWEB
git clone https://github.com/maravento/blackweb.git

# CREATE DIR
if [ ! -d $blpath/bl ]; then mkdir -p $blpath/bl; fi
if [ ! -d /etc/acl ]; then mkdir -p /etc/acl; fi

# DOWNLOAD BL
echo "Downloading Public Bls..."

function bldownload() {
    wget -c --retry-connrefused -t 0 "$1" -O - 2>/dev/null | sort -u >> $blpath/bl/bls.txt
}
bldownload 'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml' && sleep 1
bldownload 'http://malwaredomains.lehigh.edu/files/justdomains' && sleep 1
bldownload 'https://easylist-downloads.adblockplus.org/malwaredomains_full.txt' && sleep 1
bldownload 'http://www.passwall.com/blacklist.txt' && sleep 1
bldownload 'https://zeustracker.abuse.ch/blocklist.php?download=squiddomain' && sleep 1
bldownload 'http://someonewhocares.org/hosts/hosts' && sleep 1
bldownload 'http://winhelp2002.mvps.org/hosts.txt' && sleep 1
bldownload 'https://raw.githubusercontent.com/oleksiig/Squid-BlackList/master/denied_ext.conf' && sleep 1
bldownload 'http://www.joewein.net/dl/bl/dom-bl-base.txt' && sleep 1
bldownload 'http://www.joewein.net/dl/bl/dom-bl.txt' && sleep 1
bldownload 'http://www.malwaredomainlist.com/hostslist/hosts.txt' && sleep 1
bldownload 'http://adaway.org/hosts.txt' && sleep 1
bldownload 'https://openphish.com/feed.txt' && sleep 1
bldownload 'http://cybercrime-tracker.net/all.php' && sleep 1
bldownload 'http://malc0de.com/bl/ZONES' && sleep 1
bldownload 'https://ransomwaretracker.abuse.ch/downloads/RW_URLBL.txt' && sleep 1
bldownload 'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt' && sleep 1
bldownload 'http://osint.bambenekconsulting.com/feeds/dga-feed.txt' && sleep 1
bldownload 'http://hosts-file.net/download/hosts.txt' && sleep 1

function blzip() {
    cd $blpath && wget -c --retry-connrefused -t 0 "$1" >/dev/null 2>&1 && unzip -p domains.zip >> bl/bls.txt
}
blzip 'http://www.malware-domains.com/files/domains.zip' && sleep 1

function bltar() {
    cd $blpath && wget -c --retry-connrefused -t 0 "$1" >/dev/null 2>&1 && for F in *.tar.gz; do R=$RANDOM ; mkdir bl/$R ; tar -C bl/$R -zxvf $F -i; done
}
bltar 'http://www.shallalist.de/Downloads/shallalist.tar.gz' && sleep 2
bltar 'http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz' && sleep 2

function blbig() {
    cd $blpath && wget -c --retry-connrefused -t 0 "$1" -O bigblacklist.tar.gz >/dev/null 2>&1 && for F in bigblacklist.tar.gz; do R=$RANDOM ; mkdir bl/$R ; tar -C bl/$R -zxvf $F -i; done
}
blbig 'http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download&file=bigblacklist' && sleep 2

function blgz() {
    cd $blpath && wget -c --retry-connrefused -t 0 "$1" && for F in *.tgz; do R=$RANDOM ; mkdir bl/$R ; tar -C bl/$R -zxvf $F -i; done
}
blgz 'http://squidguard.mesd.k12.or.us/blacklists.tgz' && sleep 2

# DOWNLOAD TLDS
echo "Downloading Public TLDs..."

function iana() {
    wget -c --retry-connrefused -t 0 "$1" -O - >/dev/null 2>&1 | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed -e '/^#/d' | sed 's/^/./' | sort -u >> $blpath/ptlds.txt
}
iana 'https://data.iana.org/TLD/tlds-alpha-by-domain.txt'

function suffix() {
    wget -c --retry-connrefused -t 0 "$1" -O - >/dev/null 2>&1 | grep -v "//" | grep -ve "^$" | sed 's:\(.*\):\.\1:g' | sort -u | grep -v -P "[^a-z0-9_.-]" >> $blpath/ptlds.txt

# JOINT WHITELIST
echo "Joint Whitelist..."
sed -e '/^#/d' $blpath/{ptlds,whitetlds,whiteurls}.txt | sort -u > $blpath/tlds.txt

# CAPTURE AND DELETE OVERLAPPING DOMAINS
echo "Capture Domains..."

find $blpath/bl \( -name 'education' -or -name 'bank*' -or -name 'government' \) -exec rm -r {} \; >/dev/null 2>&1
mv $blpath/blackurl.txt $blpath/bl

regexp2='([a-zA-Z0-9][a-zA-Z0-9-]{1,61}\.){1,}(\.?[a-zA-Z]{2,}){1,}'
find $blpath/bl -type f -execdir sed 's/^/./' {} \; | sed 's:\(www\.\|ftp\.\|/.*\)::g' > $blpath/dtmp.txt
egrep -oi "$regexp2" $blpath/dtmp.txt | awk '{print "."$1}' > $blpath/domains.txt

echo "Delete Overlapping Domains..."
cd $blpath && chmod +x parse_domain.py && python parse_domain.py | sort -u > blackweb.txt
cp -f $blpath/{blackweb,blackdomains,whitedomains}.txt /etc/acl >/dev/null 2>&1
rm -rf $blpath

# LOG
date=`date +%d/%m/%Y" "%H:%M:%S`
echo "Blackweb for Squid: ejecucion $date" >> /var/log/syslog.log
echo Done
