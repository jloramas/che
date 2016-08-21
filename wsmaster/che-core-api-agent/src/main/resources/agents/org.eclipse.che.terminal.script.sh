#
# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Codenvy, S.A. - initial API and implementation
#

pidof che-websocket-terminal && exit

unset PACKAGES
unset SUDO
command -v tar >/dev/null 2>&1 || { PACKAGES=${PACKAGES}" tar"; }
command -v wget >/dev/null 2>&1 || { PACKAGES=${PACKAGES}" wget"; }
test "$(id -u)" = 0 || SUDO="sudo"

CHE_DIR=$HOME/che
LINUX_TYPE=$(cat /etc/os-release | grep ^ID= | tr '[:upper:]' '[:lower:]')
LINUX_VERSION=$(cat /etc/os-release | grep ^VERSION=)
MACHINE_TYPE=$(uname -m)

mkdir -p ${CHE_DIR}

########################
### Install packages ###
########################

# Red Hat Enterprise Linux 7 
############################
if echo ${LINUX_TYPE} | grep -qi "rhel"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} yum install ${PACKAGES};
    }

# Ubuntu 14.04 16.04 / Linux Mint 17 
####################################
elif echo ${LINUX_TYPE} | grep -qi "ubuntu"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} apt-get update;
        ${SUDO} apt-get -y install ${PACKAGES};
    }

# Debian 8
##########
elif echo ${LINUX_TYPE} | grep -qi "debian"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} apt-get update;
        ${SUDO} apt-get -y install ${PACKAGES};
    }

# Fedora 23 
###########
elif echo ${LINUX_TYPE} | grep -qi "fedora"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} yum -y install ${PACKAGES};
    }

# CentOS 7.1 & Oracle Linux 7.1
###############################
elif echo ${LINUX_TYPE} | grep -qi "centos"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} yum -y install ${PACKAGES};
    }

# openSUSE 13.2
###############
elif echo ${LINUX_TYPE} | grep -qi "opensuse"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} zypper install -y ${PACKAGES};
    }

# Alpine 3.3
############$$
elif echo ${LINUX_TYPE} | grep -qi "alpine"; then
    test "${PACKAGES}" = "" || {
        ${SUDO} apk update
        ${SUDO} apk add ${PACKAGES};
    }

else
    >&2 echo "Unrecognized Linux Type"
    >&2 cat /etc/os-release
    exit 1
fi

########################
### Install Terminal ###
########################
if echo ${MACHINE_TYPE} | grep -qi "x86_64"; then
    PREFIX=linux_amd64
elif echo ${MACHINE_TYPE} | grep -qi "arm5"; then
    PREFIX=linux_arm7
elif echo ${MACHINE_TYPE} | grep -qi "arm6"; then
    PREFIX=linux_arm7
elif echo ${MACHINE_TYPE} | grep -qi "arm7"; then
    PREFIX=linux_arm7
else
    >&2 echo "Unrecognized Machine Type"
    >&2 uname -a
    exit 1
fi

wget  -qO - https://codenvy.com/update/repository/public/download/org.eclipse.che.terminal.binaries.${PREFIX} | tar -C ${CHE_DIR} -xzf -
$HOME/che/terminal/che-websocket-terminal -addr :4411 -cmd /bin/bash -static $HOME/che/terminal/
