#!/bin/bash
#
# Author: https://github.com/julskinka
# https://opensource.org/licenses/GPL-3.0
#
# get more using: curl -s https://plex.tv/downloads | grep "data-event-label | less"
# Fedora64, CentOS64, Fedora32, CentOS32
plex_type="CentOS 64-bit"

### Plex Public
plex_url_download=$(curl -s "https://plex.tv/api/downloads/1.json" | python -m json.tool | grep -A1 "${plex_type}" | grep url | awk -F '"' '{print($4)}')

### Plex Pass
#plex_user=""
#plex_password=""
#plex_url_download=$(curl -s --user ${plex_user}:${plex_password} "https://plex.tv/api/downloads/1.json?channel=plexpass" | python -m json.tool | grep -A1 "${plex_type}" | grep url | awk -F '"' '{print($4)}'

plex_version_current=$(rpm -qa | grep plexmediaserver | sed -e 's/plexmediaserver-//g' -e 's/.'${plex_arch}'//g')
plex_version_new=$(echo ${plex_url_download} | awk -F '/' '{print($5)}')
plex_package=$(echo ${plex_url_download} | awk -F '/' '{print($6)}')

case ${plex_type} in
  "Fedora 32-bit"|"Fedora 64-bit" )
    pkt_manager="dnf -y "
  ;;
  "CentOS 32-bit"|"CentOS 64-bit" )
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
