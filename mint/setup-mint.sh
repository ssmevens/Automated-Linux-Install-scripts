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
ubuntu-drivers autoinstall -y


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
#wget --content-disposition https://www.noip.com/download/linux/latest && tar xf noip-duc_3.3.0.tar.gz
#cd /root/noip-duc_3.3.0/binaries && sudo apt install ./noip-duc_3.3.0_amd64.deb

# installing SC
cd /root
curl -C - -L -o ITSolutionsRemoteSupport.ClientSetup.deb "https://itsic.its-ia.com:8040/Bin/ITSolutionsRemoteSupport.ClientSetup.deb?e=Access&y=Guest"
apt-get install ./ITSolutionsRemoteSupport.ClientSetup.deb -y
apt-get install -f -y

# Download files
wget --content-disposition https://itsia-my.sharepoint.com/:u:/g/personal/etienne1204_its-ia_com/EUKK4s5msHZDrPFGM5rb6AEBEEBJ_VO6fdYt68HFitCjmQ?download=1
unzip ./mint_files.zip
cd mint_files

# installing RDP Client
apt-get install freerdp2-x11 -y
apt-get install ./rdp_manager_*.deb -y

# installing VSA
chmod +x ./KcsSetup.sh
dpkg --add-architecture i386
apt update
# install libc
apt install libc6:i386 -y

sh ./KcsSetup.sh

# setting up background
#mkdir -p /usr/local/share/images
#chown root:root ITS*.jpg
#chmod 444 ITS*.jpg login-background-2.jpg
#mv ITS*.jpg /usr/local/share/images/.
#mv login-background-2.jpg /usr/share/images/desktop-base/

# This isnt working and needs to be done differently I just havent looked into how yet.
#ed /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf <<EOF
#/^background
#s,=.*$,=/usr/share/images/desktop-base/login-background-2.jpg,
#w
#q
#EOF

# can be used to change desktop background
#gsettings set org.mate.background picture-filename "/usr/share/images/desktop-base/login-background-2.jpg"


# Put the skeleton home directory stuff into /etc/skel
cd /etc
mv skel skel.orig
mkdir skel
cd skel
tar -xzf /root/mint_files/skeleton.tar.gz
chown -R root:root /etc/skel


# Add an admin user and allow them to use sudo already doing this is d-i
#cd /root
#adduser --disabled-password --shell /bin/bash --gecos 'Admin User' admin
#adduser admin sudo
#chpasswd -e < ./mint_files/admin_password


# this is working as expected
mv /root/mint_files/ORIGINAL.jpg /usr/share/backgrounds/linuxmint/default_background.jpg
chmod 644 /usr/share/backgrounds/linuxmint/default_background.jpg


# Cleanup after ourselves
cd /root
#rm -rf /mint_files
#rm -r *.deb
