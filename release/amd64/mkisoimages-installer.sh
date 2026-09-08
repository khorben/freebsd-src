#!/bin/sh
#
# Module: mkisoimages.sh
# Author: Jordan K Hubbard
# Date:   22 June 2001
#
#
# This script is used by release/Makefile to build the (optional) ISO images
# for a FreeBSD release.  It is considered architecture dependent since each
# platform has a slightly unique way of making bootable CDs.  This script
# is also allowed to generate any number of images since that is more of
# publishing decision than anything else.
#
# Usage:
#
# mkisoimages.sh [-b] image-label image-name base-bits-dir [extra-bits-dir]
#
# Where -b is passed if the ISO image should be made "bootable" by
# whatever standards this architecture supports (may be unsupported),
# image-label is the ISO image label, image-name is the filename of the
# resulting ISO image, base-bits-dir contains the image contents and
# extra-bits-dir, if provided, contains additional files to be merged
# into base-bits-dir as part of making the image.

set -e

scriptdir=$(dirname $(realpath $0))
. ${scriptdir}/../scripts/tools.subr
. ${scriptdir}/../../tools/boot/install-boot.sh

if [ "$1" = "-b" ]; then
	MAKEFSARG="$4"
else
	MAKEFSARG="$3"
fi

if [ -f ${MAKEFSARG} ]; then
	BASEBITSDIR=`dirname ${MAKEFSARG}`
	METALOG=${MAKEFSARG}
elif [ -d ${MAKEFSARG} ]; then
	BASEBITSDIR=${MAKEFSARG}
	METALOG=
else
	echo "${MAKEFSARG} must exist"
	exit 1
fi

if [ "$1" = "-b" ]; then
	# This is highly x86-centric and will be used directly below.
	bootable="-o bootimage=i386;$BASEBITSDIR/boot/cdboot -o no-emul-boot"

	# Make EFI system partition.
	espfilename=$(mktemp /tmp/efiboot.XXXXXX)
	# ESP file size in KB.
	espsize="2048"
	if [ -f "${BASEBITSDIR}/boot/loader_ia32.efi" ]; then
		extra_args="${BASEBITSDIR}/boot/loader_ia32.efi bootia32"
	fi
	make_esp_file ${espfilename} ${espsize} ${BASEBITSDIR}/boot/loader.efi bootx64 ${extra_args}
	bootable="$bootable -o bootimage=i386;${espfilename} -o no-emul-boot -o platformid=efi"

	shift
else
	bootable=""
fi

if [ $# -lt 3 ]; then
	echo "Usage: $0 [-b] image-label image-name base-bits-dir [extra-bits-dir]"
	exit 1
fi

LABEL=`echo "$1" | tr '[:lower:]' '[:upper:]'`; shift
NAME="$1"; shift
# MAKEFSARG extracted already
shift

publisher="The FreeBSD Project.  https://www.FreeBSD.org/"
echo "/dev/iso9660/$LABEL / cd9660 ro 0 0" > "$BASEBITSDIR/etc/fstab"
cat > ${BASEBITSDIR}/boot/loader.conf.local << __EOF__
loader_menu_multi_user_prompt="CRAMAS Workshop"
__EOF__
cat > ${BASEBITSDIR}/etc/rc.conf.local << __EOF__
root_rw_mount="NO"
tmpmfs="YES"
varmfs="YES"

clear_tmp_enable="NO"
dhclient_enable="YES"
local_unbound_enable="NO"
powerd_enable="YES"
__EOF__
cat > ${BASEBITSDIR}/etc/rc.local << __EOF__
#!/bin/sh
#
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2022 Jessica Clarke <jrtc27@FreeBSD.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

bsdinstall_multicons_disabled()
{
	local var value

	var=bsdinstall.multicons_disable
	value=\`kenv -q $var\`
	case "\${value:-NO}" in
	[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1)
		return 0
		;;
	[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0)
		return 1
		;;
	*)
		warn "\$var is not set properly, ignoring"
		return 1
		;;
	esac
}

# resolv.conf from DHCP ends up in here, so make sure the directory exists
mkdir /tmp/bsdinstall_etc

# start the graphical installer
echo
#FIXME vboxguest panics, X does not seem to work
#services="vboxguest vboxservice dbus powerd slim"
services="dbus powerd"
for service in \$services; do
	/usr/sbin/service \$service onestart
done

if bsdinstall_multicons_disabled; then
	/usr/libexec/bsdinstall/startbsdinstall
else
	echo
	/usr/libexec/bsdinstall/runconsoles /usr/libexec/bsdinstall/startbsdinstall %
fi
__EOF__
mkdir -p ${BASEBITSDIR}/usr/local/etc/xdg/xsessions
cat > ${BASEBITSDIR}/usr/local/etc/xdg/xsessions/bsdinstall.desktop << __EOF__
[Desktop Entry]
Encoding=UTF-8
Name=bsdinstall
Icon=bsdinstall
Comment=The FreeBSD graphical installer
TryExec=bsdinstall-session
Exec=bsdinstall-session
Type=Application
__EOF__
mkdir -p ${BASEBITSDIR}/usr/local/bin
cat > ${BASEBITSDIR}/usr/local/bin/bsdinstall-session << __EOF__
#!/bin/sh
#\$Id\$
#Copyright (c) 2015-2024 Pierre Pronchery <khorben@defora.org>
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



#variables
[ -f "/boot/images/freebsd-logo-rev.png" ] &&
	export GBSDDIALOG_BACKTITLE_LOGO="/boot/images/freebsd-logo-rev.png"
GTK_DEFAULT_FONT="Sans 10"
GTK_DEFAULT_ICON_THEME="gnome"
GTK3_SETTINGS_INI="\$HOME/.config/gtk-3.0/settings.ini"
PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
PREFIX="/usr/local"
PROGNAME="bsdinstall-session"
SYSCONFDIR="\$PREFIX/etc"
VENDOR="FreeBSD"
#executables
CAT="cat"
DEBUG=
INSTALLER="/usr/libexec/bsdinstall/startbsdinstall -X primary"
MKDIR="mkdir -p"
WINDOWMANAGER="metacity"

#load local settings
[ -f "\$SYSCONFDIR/\$VENDOR/\$PROGNAME.conf" ] &&
	. "\$SYSCONFDIR/\$VENDOR/\$PROGNAME.conf"
[ -f "\$HOME/.config/\$VENDOR/\$PROGNAME.conf" ] &&
	. "\$HOME/.config/\$VENDOR/\$PROGNAME.conf"


#configure Gtk+ if necessary
#XXX assumes Gtk+ 3
if [ ! -f "\$GTK3_SETTINGS_INI" ]; then
	\$DEBUG \$MKDIR "\${GTK3_SETTINGS_INI%/*}" &&
		\$DEBUG \$CAT > "\$GTK3_SETTINGS_INI" << EOF
[Settings]
gtk-button-images = true
gtk-font-name = \$GTK_DEFAULT_FONT
gtk-icon-theme-name = \$GTK_DEFAULT_ICON_THEME
gtk-menu-images = true
EOF
fi

#start the Window Manager
\$DEBUG \$WINDOWMANAGER &

#start the installer
\$DEBUG \$INSTALLER
__EOF__
chmod 755 ${BASEBITSDIR}/usr/local/bin/bsdinstall-session
mkdir -p ${BASEBITSDIR}/root/.config/gtk-3.0
cat > ${BASEBITSDIR}/root/.config/gtk-3.0/settings.ini << __EOF__
[Settings]
#gtk-application-prefer-dark-theme = true
gtk-button-images = true
gtk-font-name = Sans 10
gtk-icon-theme-name = gnome
gtk-menu-images = true
__EOF__
cat > ${BASEBITSDIR}/root/.xinitrc << __EOF__
#!/bin/sh


if [ \$# -eq 0 -o "\$1" = "default" ]; then
	SESSION="bsdinstall-session"
else
	SESSION="\$@"
fi

exec \$SESSION
__EOF__
cat > ${BASEBITSDIR}/usr/local/etc/slim.conf << __EOF__
# Path, X server and arguments (if needed)
# Note: -xauth \$authfile is automatically appended
# Use default path from /etc/login.conf
default_path        /sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin
default_xserver     /usr/local/bin/X
# The X server needs to be started on an unused virtual terminal,
# for FreeBSD in a default configuration, the first one of those is #09
xserver_arguments   -nolisten tcp vt09

# Commands for halt, login, etc.
halt_cmd            /sbin/shutdown -p now
reboot_cmd          /sbin/shutdown -r now
console_cmd         /usr/local/bin/xterm -C -fg white -bg black +sb -T "Console login" -e /bin/sh -c "/bin/cat /etc/motd; exec /usr/bin/login"
suspend_cmd        /usr/sbin/acpiconf -s 3

# Full path to the xauth binary
xauth_path         /usr/local/bin/xauth

# Xauth file for server
authfile           /var/run/slim.auth


# Activate numlock when slim starts. Valid values: on|off
# numlock             on

# Hide the mouse cursor (note: does not work with some WMs).
# Valid values: true|false
# hidecursor          false

# This command is executed after a successful login.
# you can place the %session and %theme variables
# to handle launching of specific commands in .xinitrc
# depending of chosen session and slim theme
#
# NOTE: if your system does not have bash you need
# to adjust the command according to your preferred shell,
# i.e. for freebsd use:
login_cmd           exec /bin/sh - ~/.xinitrc %session
#login_cmd           exec /bin/bash -login ~/.xinitrc %session

# Commands executed when starting and exiting a session.
# They can be used for registering a X11 session with
# sessreg. You can use the %user variable
#
# sessionstart_cmd	some command
# sessionstop_cmd	some command

# Start in daemon mode. Valid values: yes | no
# Note that this can be overriden by the command line
# options "-d" and "-nodaemon"
# daemon	yes

# Option "sessions" is no longer supported.
# Now you need to put session files in the directory specified
# by option "sessiondir".
# sessions            xfce4,icewm-session,wmaker,blackbox

# Directory of session files.
# They should be xdg-style .desktop files.
# The "Name" entry in the session file would be used as session name.
# The "Exec" entry would replace %session in login_cmd.
sessiondir		/usr/local/etc/xdg/xsessions

# Executed when pressing F11 (requires imagemagick)
screenshot_cmd      import -window root /slim.png

# welcome message. Available variables: %host, %domain
welcome_msg         Welcome to %host

# Session message. Prepended to the session name when pressing F1
# session_msg         Session: 

# shutdown / reboot messages
shutdown_msg       The system is powering down...
reboot_msg         The system is rebooting...

# default user, leave blank or remove this line
# for avoid pre-loading the username.
default_user        root

# Focus the password field on start when default_user is set
# Set to "yes" to enable this feature
#focus_password      no

# Automatically login the default user (without entering
# the password. Set to "yes" to enable this feature
auto_login          yes


# current theme, use comma separated list to specify a set to 
# randomly choose from
current_theme       fbsd

# Lock file
lockfile            /var/run/slim.pid

# Log file
logfile             /var/log/slim.log

__EOF__
if [ -n "${METALOG}" ]; then
	metalogfilename=$(mktemp /tmp/metalog.XXXXXX)
	#cat ${METALOG} > ${metalogfilename}
	awk '{
    p = index($0, " type=")
    path = substr($0, 1, p - 1)
    rest = substr($0, p)
    gsub(/ /, "\\040", path)
    print path rest
}' ${METALOG} > ${metalogfilename}
	echo "./boot/loader.conf.local type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./etc/fstab type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./etc/rc.conf.local type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./root/.config/gtk-3.0/settings.ini type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./root/.xinitrc type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./usr/local/bin/bsdinstall-session type=file uname=root gname=wheel mode=0755" >> ${metalogfilename}
	echo "./usr/local/etc/xdg/xsessions/bsdinstall.desktop type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	MAKEFSARG=${metalogfilename}
fi
$MAKEFS -D -N ${BASEBITSDIR}/etc -t cd9660 $bootable -o rockridge -o label="$LABEL" -o publisher="$publisher" "$NAME" "$MAKEFSARG" "$@"
rm -f "$BASEBITSDIR/boot/loader.conf.local"
rm -f "$BASEBITSDIR/etc/fstab"
rm -f "$BASEBITSDIR/etc/rc.conf.local"
rm -f "$BASEBITSDIR/etc/rc.local"
rm -f "$BASEBITSDIR/root/.config/gtk-3.0/settings.ini"
rm -f "$BASEBITSDIR/root/.xinitrc"
rm -f ${espfilename}
if [ -n "${METALOG}" ]; then
	rm ${metalogfilename}
fi

if [ "$bootable" != "" ]; then
	# Look for the EFI System Partition image we dropped in the ISO image.
	for entry in `$ETDUMP --format shell $NAME`; do
		eval $entry
		if [ "$et_platform" = "efi" ]; then
			espstart=`expr $et_lba \* 2048`
			espsize=`expr $et_sectors \* 512`
			espparam="-p efi::$espsize:$espstart"
			break
		fi
	done

	# Create a GPT image containing the partitions we need for hybrid boot.
	hybridfilename=$(mktemp /tmp/hybrid.img.XXXXXX)
	if [ "$(uname -s)" = "Linux" ]; then
		imgsize=`stat -c %s "$NAME"`
	else
		imgsize=`stat -f %z "$NAME"`
	fi
	$MKIMG -s gpt \
	    --capacity $imgsize \
	    -b "$BASEBITSDIR/boot/pmbr" \
	    -p freebsd-boot:="$BASEBITSDIR/boot/isoboot" \
	    $espparam \
	    -o $hybridfilename

	# Drop the PMBR, GPT, and boot code into the System Area of the ISO.
	dd if=$hybridfilename of="$NAME" bs=32k count=1 conv=notrunc
	rm -f $hybridfilename
fi
