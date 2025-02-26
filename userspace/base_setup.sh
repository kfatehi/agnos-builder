#!/bin/bash -e

USERNAME=comma
PASSWD=comma
HOST=tici

# Create identification file
touch /TICI

# Create privileged user
useradd -G sudo -m -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWD" | chpasswd
groupadd gpio
groupadd gpu
adduser $USERNAME root
adduser $USERNAME video
adduser $USERNAME gpio
adduser $USERNAME adm
adduser $USERNAME gpu
adduser $USERNAME audio
adduser $USERNAME disk

# Add armhf as supported architecture
dpkg --add-architecture armhf

# Install packages
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -yq locales systemd
adduser $USERNAME systemd-journal

# Enable serial console on UART
systemctl enable serial-getty@ttyS0.service

# set kernel params
echo "net.ipv4.conf.all.rp_filter = 2" >> /etc/sysctl.conf
echo "vm.dirty_expire_centisecs = 200" >> /etc/sysctl.conf

# raise comma user's process priority limits
echo "comma - rtprio 100" >> /etc/security/limits.conf
echo "comma - nice -10" >> /etc/security/limits.conf

# Locale setup
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

apt-get upgrade -yq
apt-get install --no-install-recommends -yq \
    alsa-utils \
    apport-retrace \
    bc \
    build-essential \
    bzip2 \
    curl \
    chrony \
    cpuset \
    dfu-util \
    evtest \
    git \
    git-core \
    git-lfs \
    gdb \
    htop \
    i2c-tools \
    ifmetric \
    ifupdown \
    jq \
    landscape-common \
    libi2c-dev \
    libqmi-utils \
    libtool \
    libncursesw5-dev \
    libgdbm-dev \
    libc6-dev \
    libsqlite3-dev \
    libssl-dev \
    libffi-dev \
    llvm \
    nano \
    net-tools \
    nload \
    network-manager \
    nvme-cli \
    openssl \
    python-dev \
    python-setuptools \
    smartmontools \
    speedtest-cli \
    ssh \
    sshfs \
    sudo \
    traceroute \
    tk-dev \
    ubuntu-minimal \
    ubuntu-server \
    ubuntu-standard \
    udev \
    udhcpc \
    wget \
    wireless-tools \
    zlib1g-dev

rm -rf /var/lib/apt/lists/*

# Allow chrony to make a big adjustment to system time on boot
echo "makestep 0.1 3" >> /etc/chrony/chrony.conf

# Create dirs
mkdir /data && chown $USERNAME:$USERNAME /data
mkdir /persist && chown $USERNAME:$USERNAME /persist

# Disable automatic ondemand switching from ubuntu
systemctl disable ondemand

# Disable pstore service that moves files out of /sys/fs/pstore
systemctl disable systemd-pstore.service

# Nopasswd sudo
echo "comma ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# setup /bin/sh symlink
ln -sf /bin/bash /bin/sh

# Add bionic repo to sources
echo "" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic main restricted" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic universe" >> /etc/apt/sources.list

# Install neccesary libs
apt-get update -yq
apt-get install --no-install-recommends -yq \
    libacl1:armhf \
    libasan2-armhf-cross \
    libatomic1-armhf-cross \
    libattr1:armhf \
    libaudit1:armhf \
    libblkid1:armhf \
    libc6:armhf \
    libc6-armhf-cross \
    libc6-dev:armhf \
    libc6-dev-armhf-cross \
    libcairo2:armhf \
    libcap2:armhf \
    libdrm2:armhf \
    libevdev2:armhf \
    libexpat1:armhf \
    libffi6:armhf \
    libfontconfig1:armhf \
    libfreetype6:armhf \
    libgbm1:armhf \
    libgcc-5-dev-armhf-cross \
    libgcc1:armhf \
    libglib2.0-0:armhf \
    libgomp1-armhf-cross \
    libgudev-1.0-0:armhf \
    libinput-bin:armhf \
    libinput-dev:armhf \
    libinput10:armhf \
    libjpeg-dev:armhf \
    libjpeg-turbo8:armhf \
    libjpeg-turbo8-dev:armhf \
    libjpeg8:armhf \
    libjpeg8-dev:armhf \
    libkmod2:armhf \
    libmtdev1:armhf \
    libpam0g:armhf \
    libpam0g-dev:armhf \
    libpcre3:armhf \
    libpixman-1-0:armhf \
    libpng16-16:armhf \
    libselinux1:armhf \
    libstdc++6:armhf \
    libstdc++6-armhf-cross \
    libubsan0-armhf-cross \
    libudev-dev:armhf \
    libudev1:armhf \
    libuuid1:armhf \
    libwacom2:armhf \
    libwayland-client0:armhf \
    libwayland-cursor0:armhf \
    libwayland-server0:armhf \
    libx11-6:armhf \
    libxau6:armhf \
    libxcb-render0:armhf \
    libxcb-shm0:armhf \
    libxcb1:armhf \
    libxdmcp6:armhf \
    libxext6:armhf \
    libxkbcommon0:armhf \
    libxrender1:armhf \
    linux-libc-dev:armhf \
    linux-libc-dev-armhf-cross \
    zlib1g:armhf \
    libegl1 \
    libegl-dev \
    libgles1 \
    libgles2 \
    libgles-dev \
    libwayland-dev \
    pulseaudio \
    pulseaudio-utils \
    openssh-server \
    dnsmasq-base \
    isc-dhcp-client \
    iputils-ping \
    rsyslog \
    kmod \
    wpasupplicant \
    hostapd \
    libgtk2.0-dev \
    libcap2:armhf \
    libxml2:armhf \
