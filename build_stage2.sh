PACKAGES="syslog-ng vixie-cron =www-client/firefox-24.0-r1 gvim emacs mpv rxvt-unicode tmux weston wicd burg eix"
PACKAGES="${PACKAGES} =kde-base/kdeadmin-meta-4.11.1 =kde-base/kdebase-meta-4.11.1 =kde-base/kdebase-runtime-meta-4.11.1 =kde-base/kdemultimedia-meta-4.11.1 =kde-base/kdenetwork-meta-4.11.1 =kde-base/kdeutils-meta-4.11.1"
PACKAGES="${PACKAGES} =x11-base/xorg-server-9999-r1 oh-my-zsh"

MSGPREFIX=" !!!"


echo "$MSGPREFIX Evaluating profile"
source /etc/profile

echo "$MSGPREFIX Fetching portage tree"
emerge --sync
emerge --quiet --quiet-build --oneshot portage

echo "$MSGPREFIX Setting profile"
eselect profile set default/linux/amd64/13.0/desktop/kde

echo "$MSGPREFIX Emerging kernel and generation tools"
emerge --quiet --quiet-build gentoo-sources genkernel

echo "$MSGPREFIX Installing fstab"
echo "/dev/${DISK}  /  ext3  noatime  0 0" > /etc/fstab

echo "$MSGPREFIX Building kernel"
genkernel --no-menuconfig kernel

echo "$MSGPREFIX Emerging flaggie"
emerge --quiet --quiet-build flaggie

echo "$MSGPREFIX Emerging layman"
flaggie layman +cvs +subversion +mercurial
# to remove the massive dependency lists
flaggie dev-vcs/git -gpg -gtk
flaggie subversion -kde
###
echo " $MSGPREFIX Emerging new perl version before layman build"
# to prevent having to rebuild a bunch of perl modules later on
emerge --quiet =dev-lang/perl-5.16.1 --autounmask-write
etc-update --automode -3
emerge --quiet --quiet-build =dev-lang/perl-5.16.1
###
emerge --quiet --quiet-build layman

echo "$MSGPREFIX Installing secondary make.conf"
mv /etc/portage/make2.conf /etc/portage/make.conf

echo "$MSGPREFIX Adding overlays"
layman -o https://raw.github.com/SlashGeeSlashOS/gos-overlay/master/gos-overlay.xml -f -a gos-overlay
layman -a wavilen
layman -a qt

echo "$MSGPREFIX Adding flags"
flaggie weston +X +fbdev +opengl +wayland-compositor +xwayland
flaggie wicd +X +gtk +ncurses +libnotify
# fixes cmake build issues
flaggie cmake -qt4
###
flaggie ffmpeg +threads +vdpau

echo "$MSGPREFIX Emerging packages"
# to solve mpv conflict
echo " $MSGPREFIX Fixing mpv ffmpeg/libav package block"
emerge --quiet =media-video/ffmpeg-1.2.3 --autounmask-write
printf "media-video/libav\nmedia-video/libpostproc" >> /etc/portage/package.mask
###
# to solve systemd/eudev dependence
printf "\nsys-apps/systemd\nsys-fs/eudev" >> /etc/portage/package.mask
###
# prevents Qt4 being built
echo " $MSGPREFIX Emerging Qt5"
emerge @qt5-essentials @qt5-addons --backtrack=30 --autounmask-write
etc-update --automode -3
emerge @qt5-essentials @qt5-addons --backtrack=30
###
echo " $MSGPREFIX Unmasking packages"
emerge $PACKAGES --autounmask-write
etc-update --automode -3
# helps fix some blocks
echo " $MSGPREFIX Performing world update to fix package blocks"
emerge -uDN world
###
echo " $MSGPREFIX Emerging packages"
emerge $PACKAGES

echo "$MSGPREFIX Setting up RC"
rc-update add sshd default
rc-update add vixie-cron default
rc-update add syslog-ng default
rc-update add wicd default

printf "$MSGPREFIX Setting root password\n${MSGPREFIX} Please enter new password"
passwd

echo "$MSGPREFIX Build script completed. Please set timezone, add new users and configure bootloader before rebooting"
