PACKAGES="syslog-ng vixie-cron firefox gvim emacs mpv rxvt-unicode tmux weston wicd"
PACKAGES="${PACKAGES} =kde-base/kdeadmin-meta-4.11.1 =kde-base/kdebase-meta-4.11.1 =kde-base/kdebase-runtime-meta-4.11.1 =kde-base/kdemultimedia-meta-4.11.1 =kde-base/kdenetwork-meta-4.11.1 =kde-base/kdeutils-meta-4.11.1"

MAKECONF="CFLAGS=\"-O2 -pipe\" \n \
CXXFLAGS=\"${CFLAGS}\" \n \
CHOST=\"x86_64-pc-linux-gnu\" \n \
USE=\"bindist mmx sse sse2 X opengl gles wayland pulseaudio egl\" \n \
source /var/lib/layman/make.conf"


echo "Fetching portage tree"
cd /usr/
wget http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

echo "Unpacking portage tree"
tar -xf portage-latest.tar.bz2

echo "Setting profile"
eselect profile set default/linux/amd64/13.0/desktop/kde

echo "Emerging kernel and generation tools"
emerge --quiet --quiet-build gentoo-sources genkernel

echo "Building kernel"
genkernel --no-install --no-menuconfig bzImage

echo "Installing kernel"
cp /usr/src/linux/arch/x86/bzImage /boot/kernel

echo "Installing fstab"
echo "/dev/${DISK}  /  ext3  noatime  0 0"

echo "Emerging layman and flaggie"
emerge --quiet --quiet-build layman flaggie

echo "Installing make.conf"
echo $MAKECONF > /etc/portage/make.conf

echo "Adding aoliynik and /g/OS overlays"
layman -o http://aoliynik-overlay.googlecode.com/files/aoliynik-overlay.xml -f -a aoliynik
layman -o https://raw.github.com/SlashGeeSlashOS/gos-overlay/master/gos-overlay.xml -f -a gos-overlay

echo "Adding flags"
flaggie weston +X +fbdev +opengl +wayland-compositor +xwayland
flaggie wicd +X +gtk +ncurses +libnotify

echo "Emerging packages"
emerge -v $PACKAGES

echo "Setting up RC"
rc-update add sshd default
rc-update add vixie-cron default
rc-update add syslog-ng default
rc-update add wicd default

echo "Setting root password\nPlease enter new password"
passwd
