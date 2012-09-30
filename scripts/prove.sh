#!/bin/bash

INPUT_FILE=$1

command_exists () {
    command -v $1 >/dev/null 2>&1
}

package_name () {
    echo $1 | sed -E 's/[/]/::/g' | sed -E 's/[.]pm$//g'
}

if [ -z $1 ] ; then
    echo "Usage: prove.sh t/Test/Name.pm"
    exit 1
 fi

 if [ ! -s $1 ]; then
    echo "File does not exist: ${1}"
    exit 1
fi

if ! command_exists mx-run; then
    echo "Cannot find mx-run, did you install Test::Sweet?"
    exit 1
fi

PACKAGE_NAME=`package_name $1`

echo "RUNNING"
echo "mx-run -Ilib ${PACKAGE_NAME}"
mx-run -Ilib $PACKAGE_NAME
