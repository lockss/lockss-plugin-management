#!/bin/sh

# Copyright (c) 2000-2019, Board of Trustees of Leland Stanford Jr. University
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

if [ -z "${USER}" ]; then
  USER="$(id -un)"
  if [ -z "{USER}" ]; then
    echo "${_0}: error: could not determine \$USER"
    exit 1
  fi
fi

if [ -z "${HOME}" ]; then
  HOME="/home/${USER}"
  if [ ! -d "${HOME}" ]; then
    echo "${_0}: error: could not determine \$HOME"
    exit 1
  fi
fi

ALIAS="${USER}-lockss"
KEYSTORE="${HOME}/.ssh/plugin/${ALIAS}.keystore"
if [ ! -f "${KEYSTORE}" ]; then
  echo "${_0}: error: keystore not found: ${KEYSTORE}"
  exit 1
fi

PLUGINID="${1}"
until [ -n "${PLUGINID}" ]; do
  echo -n "Plugin identifier: "
  read PLUGINID
done

PLUGINFILE="plugins/classes/$(echo "${PLUGINID}" | sed -e 's@\.@/@g').xml"
if [ ! -f "${PLUGINFILE}" ]; then
 echo "${_0}: error: plugin file not found: ${PLUGINFILE}"
 exit 1
fi

PLUGINJAR="$(basename "${PLUGINFILE}" '.xml').jar"

test/scripts/genplugin \
  --plugin="${PLUGINFILE}" \
  --titledb="" \
  --jar="${PLUGINJAR}" \
  --alias="${ALIAS}" \
  --keystore="${KEYSTORE}"
