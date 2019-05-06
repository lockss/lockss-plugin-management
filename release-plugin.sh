#!/bin/sh

if [ "$#" = "0" -o "$#" = "1" ]; then
  echo "Usage: $0 <File.jar> <network>"
  echo "    <File.jar> A plugin JAR file"
  echo "    <network>  GLN: use one of: alliance nonalliance humanities trial"
  echo "               Non-GLN: use the network name, e.g. clockssingest"
  exit 1
fi

MYJAR=$1
NETWORK=$2

if [ ! -r $MYJAR ]; then
  echo "File not found: ${MYJAR}"
  exit 2
fi

if [ -d /srv/www/lockss-props/html ]; then
  ROOT=/srv/www/lockss-props/html
elif [ -d /home/www/props/html ]; then
  ROOT=/home/www/props/html
else
  echo "Root not found: /srv/www/lockss-props/html or /home/www/props/html"
  exit 10
fi

case "${NETWORK}" in
  alliance)
    REGISTRY=$ROOT/plugins/alliance
    ;;
  nonalliance)
    REGISTRY=$ROOT/plugins/prod
    ;;
  humanities)
    REGISTRY=$ROOT/plugins/humanities_project
    ;;
  trial)
    REGISTRY=$ROOT/plugins/trial
    ;;
  *)
    REGISTRY=$ROOT/$NETWORK/plugins
    ;;
esac

if [ ! -d $REGISTRY ]; then
  echo "No such network: ${NETWORK}"
  exit 3
fi

JARFILE=$REGISTRY/`basename $MYJAR`

if [ ! -f $JARFILE ]; then
  echo -n "New plugin in ${REGISTRY}, continue? [yn] "
  read YESNO
  if [ "X${YESNO}" = "Xy" ]; then
    cp $MYJAR $JARFILE
    chcon -t httpd_sys_content_t $JARFILE
    if [ "$?" != "0" ]; then
      echo "chcon failed with code $?"
      exit 11
    fi
  else
    echo "Aborting"
    exit 4
  fi
  ci -u $JARFILE
  if [ "$?" != "0" ]; then
    echo "ci failed with code $?"
    exit 9
  fi
elif [ "${NETWORK}" = "content-testing" ]; then
  cp $MYJAR $JARFILE
  if [ "$?" != "0" ]; then
    echo "cp failed with code $?"
    exit 5
  fi
  chcon -t httpd_sys_content_t $JARFILE
  if [ "$?" != "0" ]; then
    echo "chcon failed with code $?"
    exit 12
  fi
elif [ ! -w $JARFILE ]; then
  co -l $JARFILE
  if [ "$?" != "0" ]; then
    echo "co exited with code $?"
    exit 6
  fi
  cp $MYJAR $JARFILE
  if [ "$?" != "0" ]; then
    echo "cp failed with code $?"
    exit 7
  fi
  chcon -t httpd_sys_content_t $JARFILE
  if [ "$?" != "0" ]; then
    echo "chcon failed with code $?"
    exit 13
  fi
  ci -u $JARFILE
  if [ "$?" != "0" ]; then
    echo "ci failed with code $?"
    exit 9
  fi
else
  echo "Unknown error condition; aborting"
  exit 8
fi

