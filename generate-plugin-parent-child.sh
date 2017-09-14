#!/bin/sh

PARENTID=$1
CHILDID=$2

CHILDFILE=`echo "${CHILDID}" | sed -e 's@\.@/@g'`.xml
CHILDNAME=`basename "${CHILDFILE}" .xml`
CHILDDIR=`dirname "${CHILDFILE}"`
PARENTDIR=`dirname $(echo "${PARENTID}" | sed -e 's@\.@/@g')`
JARFILE="/tmp/${CHILDNAME}.jar"

test/scripts/jarplugin \
  -j "${JARFILE}" \
  -d "${PARENTDIR}" \
  -d "${CHILDDIR}" \
  -p "${CHILDFILE}" \
&& echo "Output: ${JARFILE}" \
&& test/scripts/signplugin \
  --jar "${JARFILE}" \
  --alias "thib-lockss" \
  --keystore "/home/thib/.ssh/plugin/thib-lockss.keystore"

