#!/bin/sh

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

P="pwdgen-1.0.0"
SRC_URI="https://github.com/iz4c810/Portage_Inside_Arch/pwdgentools/*"
WORKDIR="/var/tmp/portage/build/pwdgen-1.0.0/work"
D="/var/tmp/portage/build/pwdgen-1.0.0/image"

print_step() {
  eval "$1" > /dev/null 2>&1 &
  pid=$!

  spin="-\|/"
  i=0

  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    printf "\r${YELLOW} [%c] ${DIM}%s...${RESET}" "${spin:$i:1}" "$2"
    sleep 0.1
  done

  wait $pid
  status=$?

  if [ $status -eq 0 ]; then
    printf "\r${GREEN} [LOADING] ${RESET}%s ${GREEN}successful.${RESET}\n" "$2"
  else
    printf "\r${RED} [LOADING] ${RESET}%s ${RED}failed.${RESET}\n" "$2"
    echo "${RED} * ERROR: task failed. task canceled successfully.${RESET}"
    exit 1
  fi
}

clear
echo
