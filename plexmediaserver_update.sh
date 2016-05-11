#!/bin/bash
#
# Author: Bacon McBaconface
#
# get more using: curl -s https://plex.tv/downloads | grep "data-event-label | less"
# Fedora64, CentOS64, Fedora32, CentOS32
plex_type="CentOS64"

### Arch: i386, x86_64
plex_arch="x86_64"

### Plex Public
#plex_url_download=$(curl -s https://plex.tv/downloads | grep ${plex_type} | awk -F '"' '{print($2)}')

### Plex Pass
plex_user=""
plex_password=""
plex_url_download=$(curl -s --user ${plex_user}:${plex_password} https://plex.tv/downloads?channel=plexpass | grep ${plex_type} | awk -F '"' '{print($2)}')

plex_version_current=$(rpm -qa | grep plexmediaserver | sed -e 's/plexmediaserver-//g' -e 's/.'${plex_arch}'//g')
plex_version_new=$(echo ${plex_url_download} | awk -F '/' '{print($5)}')
plex_package=$(echo ${plex_url_download} | awk -F '/' '{print($6)}')

case ${plex_type} in
  Fedora32|Fedora64 )
    pkt_manager="dnf -y "
  ;;
  CentOS32|CentOS64 )
    pkt_manager="yum -y "
  ;;
esac

if [[ ${plex_version_current} = ${plex_version_new} ]]
then
  echo "Your plexmediaserver is up to date."
  exit 0
else
  echo "Your plexmediaserver is NOT up to date."
  sleep 3
  curl -s -o /tmp/${plex_package} ${plex_url_download}
  sudo systemctl stop plexmediaserver.service
  sleep 3
  sudo ${pkt_manager} update /tmp/${plex_package}
  sudo systemctl start plexmediaserver
  sudo systemctl status -l plexmediaserver
  exit 0
fi
