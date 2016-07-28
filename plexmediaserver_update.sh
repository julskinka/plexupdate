#!/bin/bash
#
# Copyleft 2015 Julskinka (https://github.com/julskinka)
# https://www.gnu.org/licenses/gpl.txt
#

# Fedora 64-bit, CentOS 64-bit, Fedora 32-bit, CentOS 32-bit
plex_type="CentOS 64-bit"

### Plex Public
plex_url_download=$(curl -s "https://plex.tv/api/downloads/1.json" | python -m json.tool | grep -A1 "${plex_type}" | grep url | awk -F '"' '{print($4)}')

### Plex Pass
#plex_user=""
#plex_password=""
#plex_url_download=$(curl -s --user ${plex_user}:${plex_password} "https://plex.tv/api/downloads/1.json?channel=plexpass" | python -m json.tool | grep -A1 "${plex_type}" | grep url | awk -F '"' '{print($4)}')

case ${plex_type} in
  "Fedora 32-bit"|"CentOS 32-bit" )
    plex_arch="i386"
  ;;
  "Fedora 64-bit"|"CentOS 64-bit" )
    plex_arch="x86_64"
  ;;
esac

case ${plex_type} in
  "Fedora 32-bit"|"Fedora 64-bit" )
    pkt_manager="dnf -y "
  ;;
  "CentOS 32-bit"|"CentOS 64-bit" )
    pkt_manager="yum -y "
  ;;
esac

plex_version_current=$(rpm -qa | grep plexmediaserver | sed -e 's/plexmediaserver-//g' -e 's/.'${plex_arch}'//g')
plex_version_new=$(echo ${plex_url_download} | awk -F '/' '{print($5)}')
plex_package=$(echo ${plex_url_download} | awk -F '/' '{print($6)}')


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
