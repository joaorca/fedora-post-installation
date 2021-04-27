#!/usr/bin/env bash

YELLOW="\033[1;33m"; RED="\033[0;31m"; ENDCOLOR="\033[0m"

if [ $USER != root ]; then
  echo -e "\n${RED}Error: must be root! Exiting...${ENDCOLOR}"
  exit 0
fi

echo -e "\n${YELLOW}Cleaning dnf ...${ENDCOLOR}"
dnf autoremove -y 
dnf clean all

echo -e "\n${YELLOW}Cleaning old revisions of snaps ...${ENDCOLOR}"
snap list --all | awk '/disabled/{print $1, $3}' |
while read snapname revision; do
  snap remove "${snapname}" --revision="${revision}"
done

echo -e "\n${YELLOW}Cleaning snap cache ...${ENDCOLOR}"
rm -f /var/lib/snapd/cache/*

echo -e "\n${YELLOW}Removing old kernels...${ENDCOLOR}"
dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q)

echo -e "\n${YELLOW}Emptying every trashes...${ENDCOLOR}"
rm -rf /home/*/.cache/thumbnails/*/** &> /dev/null
rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
rm -rf /root/.local/share/Trash/*/** &> /dev/null

echo -e "\n${YELLOW}Cleaning Journal ...${ENDCOLOR}"
journalctl --vacuum-time=1s

pkcon refresh force -c -1


echo -e "\n${YELLOW}Script Finished!${ENDCOLOR}"
