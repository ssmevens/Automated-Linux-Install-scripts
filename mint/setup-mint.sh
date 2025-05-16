#!/bin/sh


# See if we ever got an IP address from any networking.
SECS=90
while [ "`ip route show default`" = '' ]
do
    echo "Waiting $SECS seconds for networking"
    sleep 5
    SECS=$(expr $SECS - 5)
done
ip route show default | grep default
S=$?
if [ $S -ne 0 ]
then
    echo "No internet access. Exiting"
    exit $S
fi

# Set system to midwest timezone
cd /etc
ln -sf /usr/share/zoneinfo/US/Central localtime

# Installing chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google-chrome.asc
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
add-apt-repository multiverse
apt update
apt dist-upgrade -y
apt install google-chrome-stable -y

#drivers/ multimedia 3rd party
apt install -y ubuntu-restricted-extras
apt install -y ubuntu-drivers-common
apt install -y mint-meta-codecs


# installing and setting up UFW
apt install ufw -y
systemctl enable ufw
systemctl start

# deny incoming connections.
sudo ufw default deny incoming
# default allow out
sudo ufw default allow outgoing

# installing no-ip
cd /root
wget --content-disposition https://www.noip.com/download/linux/latest && tar xf noip-duc_3.3.0.tar.gz
cd /root/noip-duc_3.*.*/binaries && sudo apt install ./noip-duc_3.*.*_amd64.deb

# Create noip service
sudo cp /root/noip-duc_3.*.*/debian/service /etc/systemd/system/noip-duc.service

# Creating noip-duc config file
tee /etc/default/noip-duc > /dev/null <<EOF
## File: /etc/default/noip-duc
NOIP_USERNAME=
NOIP_PASSWORD=
NOIP_HOSTNAMES=
EOF

# installing SC
cd /root
curl -C - -L -o ITSolutionsRemoteSupport.ClientSetup.deb "https://itsic.its-ia.com:8040/Bin/ITSolutionsRemoteSupport.ClientSetup.deb?e=Access&y=Guest"
apt-get install ./ITSolutionsRemoteSupport.ClientSetup.deb -y
apt-get install -f -y

# Download files
cd /root
apt install git -y
git clone https://github.com/ssmevens/mint_files.git && cd mint_files
cp ./apparmor/* /etc/apparmor.d/


# installing RDP Client
apt-get install freerdp2-x11 -y
apt-get install ./rdp_manager_*.deb -y

# installing VSA
chmod +x ./KcsSetup.sh
dpkg --add-architecture i386
apt update
# install libc
apt install libc6:i386 -y

bash ./KcsSetup.sh


# Put the skeleton home directory stuff into /etc/skel
cd /etc
mv skel skel.orig
mkdir skel
cd skel
cp -r /root/mint_files/skeleton/* /etc/skel
chown -R root:root /etc/skel
chmod +x /etc/skel/Desktop/*.desktop


# this is working as expected
mv /root/mint_files/ORIGINAL.jpg /usr/share/backgrounds/linuxmint/default_background.jpg
chmod 644 /usr/share/backgrounds/linuxmint/default_background.jpg

# Uninstalling Firefox
apt-get remove firefox -y


# Cleanup after ourselves
cd /root
#rm -rf /mint_files
#rm -r *.deb

 #====================== GRUB Bootloader Installation ======================

# Set strict error handling - script will exit on any error
# -e: Exit immediately if a command returns non-zero status
# -u: Treat unset variables as errors
# -o pipefail: Return value of pipeline is status of last command to exit with non-zero status
set -euo pipefail

# Define disk device paths
# Main disk device (not partition) - modify if using different disk
DISK="/dev/sda"        
# EFI System Partition - modify if using different partition
EFI_PART="/dev/sda1"   

# -------- Legacy BIOS Installation --------
# Install GRUB for BIOS systems by writing to Master Boot Record (MBR)
# Uses i386-pc target for legacy boot compatibility
grub-install --target=i386-pc "$DISK"

# -------- UEFI Installation --------
# Create and mount EFI partition mount point
mkdir -p /boot/efi
mount "$EFI_PART" /boot/efi

# Install GRUB for UEFI systems with special options:
# --target=x86_64-efi: Use 64-bit UEFI target
# --efi-directory: Specify where EFI partition is mounted
# --bootloader-id: Name that appears in EFI boot menu
# --no-nvram: Don't update NVRAM boot entries
# --removable: Install for removable media support
grub-install --target=x86_64-efi \
             --efi-directory=/boot/efi \
             --bootloader-id=GRUB \
             --no-nvram \
             --removable

# -------- Fallback Boot Path --------
# Create standardized fallback boot path for maximum compatibility
# This allows booting even if NVRAM entries are missing/corrupted
mkdir -p /boot/efi/EFI/BOOT
cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI

# -------- Configuration Generation --------
# Generate GRUB configuration file based on current system
# Detects all bootable operating systems and creates boot menu
update-grub
