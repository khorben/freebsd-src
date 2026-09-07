#!/bin/sh
#
# This script generates an "installer image" (image that can be copied to a
# USB memory stick) from a directory tree.  Note that the script does not
# clean up after itself very well for error conditions on purpose so the
# problem can be diagnosed (full filesystem most likely but ...).
#
# Usage: make-installer.sh <directory tree or manifest> <image filename>
#
#

set -e

scriptdir=$(dirname $(realpath $0))
. ${scriptdir}/../../tools/boot/install-boot.sh

if [ "$(uname -s)" = "FreeBSD" ]; then
	PATH=/bin:/usr/bin:/sbin:/usr/sbin
	export PATH
fi

if [ $# -ne 2 ]; then
	echo "make-installer.sh /path/to/directory/or/manifest /path/to/image/file"
	exit 1
fi

MAKEFSARG=${1}

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

if [ -e ${2} ]; then
	echo "won't overwrite ${2}"
	exit 1
fi

echo '/dev/ufs/FreeBSD_Install / ufs ro,noatime 1 1' > ${BASEBITSDIR}/etc/fstab
cat > ${BASEBITSDIR}/boot/loader.conf.local << __EOF__
loader_menu_multi_user_prompt="Graphical Installer"
__EOF__
cat > ${BASEBITSDIR}/etc/rc.conf.local << __EOF__
root_rw_mount="NO"
tmpmfs="YES"
varmfs="YES"

clear_tmp_enable="NO"
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
services="vboxguest vboxservice dbus powerd slim"
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
	cat ${METALOG} > ${metalogfilename}
	echo "./etc/fstab type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./etc/rc.conf.local type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./root/.config/gtk-3.0/settings.ini type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	echo "./root/.xinitrc type=file uname=root gname=wheel mode=0644" >> ${metalogfilename}
	MAKEFSARG=${metalogfilename}
fi
makefs -D -N ${BASEBITSDIR}/etc -B little -o label=FreeBSD_Install -o version=2 ${2}.part ${MAKEFSARG}
if [ -n "${METALOG}" ]; then
	rm ${metalogfilename}
fi

# Make an ESP in a file.
espfilename=$(mktemp /tmp/efiboot.XXXXXX)
if [ -f "${BASEBITSDIR}/boot/loader_ia32.efi" ]; then
	make_esp_file ${espfilename} ${fat32min} ${BASEBITSDIR}/boot/loader.efi bootx64 \
	    ${BASEBITSDIR}/boot/loader_ia32.efi bootia32
else
	make_esp_file ${espfilename} ${fat32min} ${BASEBITSDIR}/boot/loader.efi
fi

mkimg -s mbr \
    -b ${BASEBITSDIR}/boot/mbr \
    -p efi:=${espfilename} \
    -p freebsd:-"mkimg -s bsd -b ${BASEBITSDIR}/boot/boot -p freebsd-ufs:=${2}.part" \
    -a 2 \
    -o ${2}
rm ${espfilename}
rm ${2}.part

