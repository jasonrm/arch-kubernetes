#!/bin/bash

# Boilerplate for loading variables
# > Source: http://stackoverflow.com/a/246128/31341
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# > Source: http://stackoverflow.com/a/1423444/31341
for f in $DIR/conf.d/*; do source $f; done

LOCAL_DIR=$1
LOCAL_SCRIPT=$2

source local.d/${LOCAL_DIR}/${LOCAL_SCRIPT}.sh
