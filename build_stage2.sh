PACKAGES="syslog-ng vixie-cron firefox gvim emacs mpv rxvt-unicode tmux weston wicd burg"
PACKAGES="${PACKAGES} =kde-base/kdeadmin-meta-4.11.1 =kde-base/kdebase-meta-4.11.1 =kde-base/kdebase-runtime-meta-4.11.1 =kde-base/kdemultimedia-meta-4.11.1 =kde-base/kdenetwork-meta-4.11.1 =kde-base/kdeutils-meta-4.11.1"
PACKAGES="${PACKAGES} =x11-base/xorg-server-9999-r1 oh-my-zsh @qt5-essentials @qt5-addons"


echo "!!! Evaluating profile"
source /etc/profile

echo "!!! Fetching portage tree"
emerge-webrsync

echo "!!! Setting profile"
eselect profile set default/linux/amd64/13.0/desktop/kde

echo "!!! Emerging kernel and generation tools"
emerge --quiet --quiet-build gentoo-sources genkernel

echo "!!! Building kernel"
genkernel --no-menuconfig kernel

echo "!!! Installing fstab"
echo "/dev/${DISK}  /  ext3  noatime  0 0" > /etc/fstab

echo "!!! Emerging layman and flaggie"
emerge --quiet --quiet-build flaggie
flaggie layman +cvs +subversion
emerge --quiet --quiet-build layman

echo "!!! Installing secondary make.conf"
mv /etc/portage/make2.conf /etc/portage/make.conf

echo "!!! Adding overlays"
layman -o http://aoliynik-overlay.googlecode.com/files/aoliynik-overlay.xml -f -a aoliynik
layman -o https://raw.github.com/SlashGeeSlashOS/gos-overlay/master/gos-overlay.xml -f -a gos-overlay
layman -a qt

echo "!!! Adding flags"
flaggie weston +X +fbdev +opengl +wayland-compositor +xwayland
flaggie wicd +X +gtk +ncurses +libnotify

echo "!!! Emerging packages"
emerge -v $PACKAGES

echo "!!! Setting up RC"
rc-update add sshd default
rc-update add vixie-cron default
rc-update add syslog-ng default
rc-update add wicd default

echo "!!! Setting root password\n!!! Please enter new password"
passwd

echo "!!! Build script completed. Please set timezone, add new users and configure bootloader before rebooting"
