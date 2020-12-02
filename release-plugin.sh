#!/bin/sh

# Copyright (c) 2000-2020, Board of Trustees of Leland Stanford Jr. University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

_0="$(basename "${0}")"

if [ $# -lt 2 ]; then
  echo "Usage: ${_0} <File.jar> <network>"
  echo "    <File.jar> A plugin JAR file"
  echo "    <network>  GLN: use one of: alliance nonalliance humanities"
  echo "               Non-GLN: use the network name, e.g. clockssingest"
  exit 1
fi

MYJAR="${1}"
NETWORK="${2}"

if [ ! -r "${MYJAR}" ]; then
  echo "${_0}: error: file not found: ${MYJAR}"
  exit 2
fi

if [ -d '/var/www/props.lockss.org' ]; then
  ROOT='/var/www/props.lockss.org'
else
  echo "{$_0}: error: root directory not found: /var/www/props.lockss.org"
  exit 10
fi

case "${NETWORK}" in
  alliance)
    REGISTRY="${ROOT}/plugins/alliance"
    ;;
  nonalliance)
    REGISTRY="${ROOT}/plugins/prod"
    ;;
  humanities)
    REGISTRY="${ROOT}/plugins/humanities_project"
    ;;
  *)
    REGISTRY="${ROOT}/${NETWORK}/plugins"
    ;;
esac

if [ ! -d "${REGISTRY}" ]; then
  echo "${_0}: error: network directory not found: ${REGISTRY}"
  exit 3
fi

JARFILE="${REGISTRY}/$(basename "${MYJAR}")"

if command -v selinuxenabled > /dev/null && selinuxenabled && command -v chcon > /dev/null ; then
  CHCON='chcon'
else
  CHCON=':'
fi

if [ ! -f "${JARFILE}" ]; then
  echo -n "New plugin in ${REGISTRY}, continue? [yn] "
  read YESNO
  if [ "X${YESNO}" = "Xy" ]; then
    cp "${MYJAR}" "${JARFILE}"
    if [ $? != 0 ]; then
      echo "${_0}: error: cp failed around line ${LINENO}"
      exit 14
    fi
    $CHCON -t httpd_sys_content_t "${JARFILE}"
    if [ $? != 0 ]; then
      echo "${_0}: error: chcon failed around line ${LINENO}"
      exit 11
    fi
  else
    echo "Aborting"
    exit 4
  fi
  ci -u "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: ci failed around line ${LINENO}"
    exit 9
  fi
elif [ "${NETWORK}" = 'content-testing' ]; then
  cp "${MYJAR}" "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: cp failed around line ${LINENO}"
    exit 5
  fi
  $CHCON -t httpd_sys_content_t "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: chcon failed around line ${LINENO}"
    exit 12
  fi
elif [ ! -w "${JARFILE}" ]; then
  co -l "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: co exited around line ${LINENO}"
    exit 6
  fi
  cp "${MYJAR}" "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: cp failed around line ${LINENO}"
    exit 7
  fi
  $CHCON -t httpd_sys_content_t "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: chcon failed around line ${LINENO}"
    exit 13
  fi
  ci -u "${JARFILE}"
  if [ $? != 0 ]; then
    echo "${_0}: error: ci failed around line ${LINENO}"
    exit 9
  fi
else
  echo "${_0}: unknown error condition; aborting"
  exit 8
fi

