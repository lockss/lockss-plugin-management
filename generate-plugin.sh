#!/bin/sh

PLUGINID="$1"
if [ "X${PLUGINID}" = "X" ]; then
 echo -n "Plugin identifier: "
 read PLUGINID
fi

PLUGINFILE="plugins/classes/"`echo "${PLUGINID}" | sed -e 's@\.@/@g'`".xml"
if [ ! -f "${PLUGINFILE}" ]; then
 echo "File not found: ${PLUGINFILE}"
 exit 1
fi

PLUGINJAR=`basename "${PLUGINFILE}" .xml`".jar"

test/scripts/genplugin \
  --plugin="${PLUGINFILE}" \
  --titledb="" \
  --jar="${PLUGINJAR}" \
  --alias="thib-lockss" \
  --keystore="/home/thib/.ssh/plugin/thib-lockss.keystore" \

