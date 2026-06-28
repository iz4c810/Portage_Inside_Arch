#!/bin/sh

# ─── COLOR PALETTE CONFIGURATION ─────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── PORTAGE COMPILATION CONFIGURATION ───────────────────────────────────────
P="pwdgen-1.0.0"
SRC_URI="https://githubusercontent.com/iz4c810/Portage_Inside_Arch/pwdgentools/*" # Update to your real repository
WORKDIR="/var/tmp/portage/app-crypt/pwdgen-1.0.0/work"
D="/var/tmp/portage/app-crypt/pwdgen-1.0.0/image"

# ─── HELPER FUNCTIONS ────────────────────────────────────────────────────────
# Prints an elegant step banner
print_step() {
    echo "\n${BOLD}${CYAN}  [STEP $1/$2] $3${RESET}"
    echo "${DIM}──────────────────────────────────────────────────${RESET}"
}

# Displays a spinning wheel loader while a background process runs
run_with_spinner() {
    # Start the passed command string in the background
    eval "$1" > /dev/null 2>&1 &
    pid=$!
    
    # Simple character cycle array for terminal rotation
    spin='-\|/'
    i=0
    
    # Loop while the process ID remains alive in memory tables
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${YELLOW} [%c] ${DIM}%s...${RESET}" "${spin:$i:1}" "$2"
        sleep 0.1
    done
    
    # Capture final exit status code
    wait $pid
    status=$?
    
    if [ $status -eq 0 ]; then
        printf "\r${GREEN} [LOADING] ${RESET}%s ${GREEN}successful.${RESET}\n" "$2"
    else
        printf "\r${RED} [LOADING] ${RESET}%s ${RED}failed!${RESET}\n" "$2"
        echo "${RED} * ERROR: Task failure halted application installation sequence.${RESET}"
        exit 1
    fi
}

# ─── APPLICATION LOGIC PIPELINE ──────────────────────────────────────────────
clear
echo "${BOLD}${CYAN}"
echo "  ██████╗ ██╗    ██╗██████╗  ██████╗ ███████╗███╗   ██╗"
echo "  ██╔══██╗██║    ██║██╔══██╗██╔════╝ ██╔════╝████╗  ██║"
echo "  ██████╔╝██║ █╗ ██║██║  ██║██║  ███╗█████╗  ██╔██╗ ██║"
echo "  ██╔═══╝ ██║███╗██║██║  ██║██║   ██║██╔══╝  ██║╚██╗██║"
echo "  ██║     ╚███╔███╔╝██████╔╝╚██████╔╝███████╗██║ ╚████║"
echo "  ╚═╝      ╚══╝╚══╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝"
echo "                   ${DIM}v1.0.0 - PWDGEN-Installer-tool${RESET}\n"

# Enforce system write administration privileges early 
if [ "$(id -u)" -ne 0 ]; then
    echo "${RED}  Error: Privileged environment required.${RESET}"
    echo " Please relaunch the application utilizing: ${YELLOW}sudo ./install.sh${RESET}\n"
    exit 1
fi

echo "${GREEN}  Elevated execution verified. Initiating building sequence...${RESET}"

# ─── EXECUTING PIPELINE STAGES ───────────────────────────────────────────────

print_step "1" "5" "Verifying Host System Core Dependencies"
if ! command -v gcc >/dev/null 2>&1; then
    echo "${RED}  [DEPS] Dependency 'gcc' compiler missing! Installing...${RESET}"
    pacman -S --needed --noconfirm gcc
else
    echo "${GREEN}  [DEPS] GCC compilation engine detected.${RESET}"
fi

print_step "3" "5" "Using 'curl' to fetch core components"

rm -rf /var/tmp/portage/build/pwdgen-1.0.0
mkdir -p "$WORKDIR"

for file in passgen_main.py steg_proc.py binfmt_helper.c; do
  echo " ${DIM}---> Downloading: $file...${RESET}
  curl -s -o "WORKDIR/$file "RAW_URL/$file"

  if [ ! -s "$WORKDIR/$file" ]; then
    echo "${RED} Error: Failed to fetch $file from webaddr.${RESET}"
    exit 1
  fi
done

echo "${GREEN} [FETCH] all target applications fetched.${RESET}"

print_step "3" "5" "Executing Low-Level Binary Compilations"
cd "$WORKDIR"
run_with_spinner "gcc -O3 binfmt_helper.c -o binfmt_helper" "Compiling C path-validation gate with architecture-O3 optimizations"

# Bundle python code matrices cleanly inside Portage image path standard workspace
mkdir -p "${WORKDIR}/sandbox_modules"
cp "${WORKDIR}/passgen_main.py" "${WORKDIR}/sandbox_modules/__main__.py"
cp "${WORKDIR}/steg_proc.py" "${WORKDIR}/sandbox_modules/steg_proc.py"

run_with_spinner "python3 -m zipapp sandbox_modules -o app.pbin" "Packing Python steganography layers into monolithic zipapp"

# Attach unique signature metadata 
printf "PBIN\x01\x02\x03\x04" > "${WORKDIR}/final_app.pbin"
cat "${WORKDIR}/app.pbin" >> "${WORKDIR}/final_app.pbin"

run_with_spinner "gcc -03 ${WORKDIR}/binfmt_helper.c -o ${WORKDIR}/binfmt_helper" "Compiling C path-vslidation gate with architecture-03 optimisations"

print_step "4" "5" "Staging File Structures to Temporary Image Workspace"
run_with_spinner "mkdir -p $D/usr/bin/pwdgen $D/var/passwords && cp final_app.pbin $D/usr/bin/pwdgen/app.pbin && cp binfmt_helper $D/usr/bin/pwdgen/binfmt_helper && ln -sf /usr/bin/pwdgen/app.pbin $D/usr/bin/genpwd && chmod 755 $D/usr/bin/pwdgen/* && chmod 777 $D/var/passwords" "Structuring folders, permissions, and internal links"

print_step "5" "5" "Merging Application Package into Active Production Paths"
# Copy cleanly to system files, then immediately flash the Linux Kernel's handling rule node
run_with_spinner "cp -r $D/* / && mount -t binfmt_misc none /proc/sys/fs/binfmt_misc 2>/dev/null && ( [ -f /proc/sys/fs/binfmt_misc/pbin ] && echo -1 > /proc/sys/fs/binfmt_misc/pbin || true ) && echo ':pbin:M::PBIN\x01\x02\x03\x04::/usr/bin/pwdgen/binfmt_helper:F' > /proc/sys/fs/binfmt_misc/register && rm -rf /var/tmp/portage/app-crypt/pwdgen-1.0.0" "Writing system files and registering custom .pbin format directly to Kernel"

# ─── FINALIZE SYSTEM STATUS OUTPUT ───────────────────────────────────────────
echo "\n${BOLD}${GREEN}  CONFIGURATION SUCCESSFUL!${RESET}"
echo " ${GREEN}*${RESET} System isolated binary path compiled at: ${DIM}/usr/bin/pwdgen/${RESET}"
echo " ${GREEN}*${RESET} Steganography output path open for inputs at: ${DIM}/var/passwords/${RESET}"
echo " ${GREEN}*${RESET} Kernel intercept active for magic prefix header bytes."
echo "\n You can now call your custom command line tool globally from anywhere using:"
echo " ${BOLD}${YELLOW}   genpwd${RESET}\n"
